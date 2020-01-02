# frozen_string_literal: true

# In algebraic effects, handler is an first-class object.
class Ruff::Handler
  # makes a new handler, internally having fresh empty hash.
  #
  # This is a effect-handler store and when handliong it is looked up.
  # Value handler is set an identity function to by default.

  class Store
    # is a private class to manage registered handlers
    def initialize
      @handler = {}
    end

    def []=(r, e)
      @handler[r.id] = e
    end

    def [](eff)
      # get a set {(eff', f) | forall (eff', f) in store. eff <: eff'}
      fns = @handler.filter do |effky, _fun|
        eff.id.is_a? effky.class
      end

      # pick a function with *smallest* effect class
      return fns.min_by { |effky, _| effky.class }[1] unless fns.empty?

      # if found nothing
      nil
    end
  end

  private_constant :Store

  # @example
  #   handler = Handler.new
  def initialize
    @handlers = Store.new
    @valh = ->(x) { x }
  end

  # sets value handler `&fun`.
  #
  # Value handler is the handler for *the result value of the computation*.
  # For example, `Handler.new.to{|_x| 0}.run { value }` results in `0` .
  #
  # The value handler modifies the result of the call of continuation
  # in effect handlers of the handler.
  #
  # @param [Proc<A, B>] fun
  #   value handler
  # @return [Handler<A!{e}, B!{e'}>]
  #
  # @example
  #   logs = []
  #   handler.on(Log) {|k, msg|
  #     logs << msg
  #     k[]
  #   }.to {|x|
  #    logs.each {|log|
  #      puts "Logger: #{log}"
  #    }
  #
  #     puts "returns #{x}"
  #   }
  #   .run {
  #     Log.perform "hello"
  #     Log.perform "world"
  #     "!"
  #   }
  #
  #   ## ==>
  #   # msg>> hello
  #   # msg>> world
  #   # returns !
  def to(&fun)
    @valh = fun

    self
  end

  # sets or updates effec handler `&fun` for `eff`
  #
  # Note that `eff` can be a supertype of an effect to be caught.
  # @see Effect.<<
  #
  # @param [Effect<Arg, Ret>] eff
  #   the effect instance to be handled
  # @param [Proc<Arg, Ret => A>] fun
  #   a handler to handle `eff`;
  #   First argument of `&fun` is *continuation*, proc object
  #   to go back to the handled computation.
  # @return [Handler<A!{Effect<Arg, Ret>, e}, B!{e}>]
  #   itself updated with handling `Effect<Arg, Ret>`
  #
  # @example
  #   handler.on(Log) {|k, msg|
  #     puts "Logger: #{msg}"
  #     k[]
  #   }
  def on(eff, &fun)
    @handlers[eff] = fun

    self
  end

  # handles the computation.
  #
  # @param [Proc<(), A>] prc
  #   a thunk to be handled and returns `A`
  # @return [B]
  #   a value modified by value handler `Proc<A, B>` ,
  #   or returned from the effect handler throwing continuation away
  #
  # @example
  #   handler.run {
  #     Log.perform "hello"
  #   }
  #
  # @example `handler` can be layered.
  #   handler.run {
  #     Handler.new
  #       .on(Double){|k, v|
  #         k[v * v]
  #       }.run {
  #         v = Double.perform 3
  #         Log.perform 3
  #     }
  #   }
  def run(&prc)
    co = Fiber.new(&prc)

    continue(co).call(nil)
  end

  protected

  # receives `handlers` as new handlers.
  def handlers=(handlers)
    @handlers = handlers.dup
  end

  def continue(co)
    ->(*arg) { handle(co, co.resume(*arg)) }
  end

  # rubocop:disable Metrics/AbcSize
  def handle(co, r)
    case r
    when Ruff::Throws::Eff
      if (effh = @handlers[r])
        effh[continue(co), *r.args]
      else
        Fiber.yield Ruff::Throws::Resend.new(r, continue(co))
      end
    when Ruff::Throws::Resend then
      eff = r.eff
      next_k = rehandles(co, r.k)

      if (effh = @handlers[eff])
        effh.call(next_k, *eff.args)
      else
        Fiber.yield Ruff::Throws::Resend.new(eff, next_k)
      end
    else
      @valh.call(r)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def rehandles(co, k)
    newh = self.class.new

    newh.handlers = @handlers

    lambda { |*args|
      newh
        .to { |v| continue(co).call(v) }
        .run { k.call(*args) }
    }
  end
end
