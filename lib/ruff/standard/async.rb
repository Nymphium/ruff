# frozen_string_literal: true

# `Async` provides effects `Async.async`, `Async.yield` and `Async.await`, and the implementation async/await.
# This implementation is based on the tutorial for Multicore OCaml.
# @see https://github.com/ocamllabs/ocaml-effects-tutorial/blob/master/sources/solved/async_await.ml
#
# The module has an instance of `Instance` and provides its methods as module method.
# @see Standard::Async::Instance
# @example
#   Async.with do
#     task = lambda { |name|
#       lambda {
#         puts "Starting #{name}"
#         v = (Random.rand * (10**3)).floor
#         puts "Yielding #{name}"
#         Async.yield
#         puts "Eidnig #{name} with #{v}"
#
#         v
#       }
#     }
#
#     pa = Async.async(task.call('a'))
#     pb = Async.async(task.call('b'))
#     pc = Async.async lambda {
#       Async.await(pa) + Async.await(pb)
#     }
#
#     puts "sum is #{Async.await pc}"
#   end
#   #==>
#   # Starting a
#   # Yielding a
#   # Eidnig a with 423
#   # Starting b
#   # Yielding b
#   # Eidnig b with 793
#   # sum is 1216
module Ruff::Standard::Async
  class Instance
    require 'ostruct'
    require 'ruff/standard/util'

    # are ADT-like classes which have only getter method.
    # These are used internally.
    #
    # type 'a promise =
    #   | Waiting of ('a, unit) continuation list
    #   | Done of 'a
    _Waiting = Util::ADT.create
    _Done = Util::ADT.create

    # makes a new instance.
    def initialize
      # delegates effect instances.
      @eff = OpenStruct.new(
        async: Ruff.instance,
        yield: Ruff.instance,
        await: Ruff.instance
      )

      # is a proc queue.
      @q = Util::FnStack.new
    end

    # is a smart method to invoke the effect operation `Async.async` .
    # @param [Proc<(), A>] th
    #   is a thunk asynchronously computed.
    # @return [Promise<A>]
    #   with `with` , returns `Promise<A>` with running concurrently .
    def async(th)
      @eff.async.perform th
    end

    # is a smart method to invoke the effect operation `Async.yield` .
    # @return [()]
    #   with `with` , yields the control to another task.
    def yield
      @eff.yield.perform
    end

    # is a smart method to invoke the effect operation `Async.await` .
    # @param [Promise<A>] p
    #   is a promise to run.
    # @return [A]
    #   with `with` returns the result of *promise* computation.
    def await(p)
      @eff.await.perform p
    end

    # @method with
    # @param [Proc<(), _A!{Async.async, Async.yield, Async.await, e}>] th
    #   is a thunk returning `_A` with te possibility to invoke effects,
    #   including `Async.async` , `Async.yield` and `Async.await` .
    # @return [()!{e}]
    #   returns unit but still has the possibility to invoke effects `e` .
    define_method :with do |&th|
      fork(Util::Ref.new(_Waiting.new([])), th)
    end

    # You can reimplement the handler using these effect instances
    # with accessing `Async.async` , `Async.yield` , and `Async.await` .
    attr_reader :eff

    private

    define_method :fork do |pr, th|
      Ruff.handler
          .to do |v|
        pp = pr.get
        l = case pp
            when _Waiting
              pp.get
            else
              raise 'impossible'
            end

        l.each do |k|
          @q.enqueue(-> { k[v] })
        end

        pr.set(_Done.new(v))
        @q.dequeue
      end
          .on(@eff.async) do |k, f|
        pr_ = Util::Ref.new(_Waiting.new([]))
        @q.enqueue(-> { k[pr_] })
        fork(pr_, f)
      end
          .on(@eff.yield) do |k|
        @q.enqueue(-> { k[] })
        @q.dequeue.call
      end
          .on(@eff.await) do |k, pr|
        pp = pr.get

        return case pp
               when _Done
                 k[pp.get]
               when _Waiting
                 pr.set(_Waiting.new(@q.cons(k)))
                 @q.dequeue.call
               end
      end
          .run { th[] }
    end
  end

  # ---
  @inst = Instance.new
  @eff = @inst.eff

  # @see Instance#async
  def async(asynth)
    @inst.async asynth
  end

  # @see Instance#await
  def await(p)
    @inst.await p
  end

  # @see Instance#yield
  def yield
    @inst.yield
  end

  # @see Instance#with
  def with(&th)
    @inst.with(&th)
  end

  module_function :async, :await, :yield, :with

  # @see Instance#eff
  attr_reader :eff
end
