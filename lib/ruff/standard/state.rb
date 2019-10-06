# frozen_string_literal: true

# `State` provides effects `State.get` and `State.modify` ,
# and the implementation of the mutable cell or so-called *state* .
#
# The module has an instance of `Instance` and provides its methods as module method.
# @see Standard::State::Instance
# @example
#   r = State.with {
#     State.put 10
#     puts State.get #==> 10
#     State.modify {|s| s + 20}
#     State.modify {|s|
#       puts s #==> 30
#       0
#     }
#
#     puts State.get #==> 0
#
#     State.put 11
#   }
#
#   puts r #==> 11
module Ruff::Standard::State
  class Instance
    require 'ostruct'

    # makes new instances.
    def initialize
      # delegates effect instances.
      @eff = OpenStruct.new(
        get: Ruff.instance,
        modify: Ruff.instance
      )
    end

    # is a smart method to invoke the effect operation `State.get` .
    # @return [S]
    #   with `with` , returns `S` , the current state.
    def get
      @eff.get.perform
    end

    # is a smart hetmod to invoke the effect operation `State.modify` .
    # @param [Proc<S, U>] fn
    #   is the function to modify the state `S` to `U` .
    #   This function has an argument receiving the state.
    # @return [()]
    def modify(&fn)
      @eff.modify.perform fn
    end

    # is a short hand for `modify {|_| s }`
    # @param [S] s
    #   is the new state.
    # @return [()]
    def put(s)
      @eff.modify.perform ->(_) { s }
    end

    # is a handler to interpret the effect invocations like *state monad* .
    #
    # @param [S] init
    #   is the initial state.
    # @param [Proc<(), A!{State.get, State.modify,, e}>] th
    #  is a thunk returning `A` with the possibility to invoke effects,
    #  including `State.get` and `State.modify` .
    # @return [A!{e}]
    #   returns `A` , without modification by value handler.
    #   But it still has the possibility to invoke effects(`e`).
    def with_init(init, &th)
      # not a parameter passing style, or so-called *pure* implementation,
      # just using mutable assignment
      state = init

      # The handler *closes* `state` variable so it should be created every time.
      Ruff.handler
          .on(@eff.modify) do |k, fn|
        state = fn[state]
        k[nil]
      end.on(@eff.get) do |k|
        k[state]
      end
          .run(&th)
    end

    # is a short hand for `with_init(nil, th)` .
    #
    # @param [Proc<(), A!{State.get, State.modify,, e}>] th
    #  is a thunk returning `A` with the possibility to invoke effects,
    #  including `State.get` and `State.modify` .
    # @return [A!{e}]
    #   returns `A` , without modification by value handler.
    #   But it still has the possibility to invoke effects(`e`).
    def with(&th)
      with_init(nil, &th)
    end

    # You can reimplement the handler using these effect instances
    # with accessing `#eff.get` and `#eff.modify` .
    attr_reader :eff
  end

  # ---
  @inst = Instance.new
  @eff = @inst.eff

  # @see Instance#get
  def get
    @inst.get
  end

  # @see Instance#modify
  def modify(&fn)
    @inst.modify(&fn)
  end

  # @see Instance#put
  def put(s)
    @inst.put s
  end

  # @see Instance#with_init
  def with_init(init, &task)
    @inst.with_init init, &task
  end

  # @see Instance#with
  def with(&task)
    @inst.with(&task)
  end

  module_function :get, :put, :modify, :with, :with_init

  # @see Instance#eff
  attr_reader :eff
end
