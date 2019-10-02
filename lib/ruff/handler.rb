require 'securerandom'

# In algebraic effects, handler is an first-class object.
class Ruff::Handler
  include Ruff::Throws

  # makes a new handler, internally having fresh empty hash.
  #
  # This is a effect-handler store and when handliong it is looked up.
  # Value handler is set `id` function to by default.
  #
  # @example
  #   handler = Handler.new

  def initialize
    @handlers = Hash.new
    @valh_id = SecureRandom.uuid
    @handlers[@valh_id] = ->(x) { x }
  end


  # sets value handler `&fun`.
  #
  # Value handler is the handler for *the result value of the computation*.
  # For example, `Handler.new.to{|_x| 0}.run { value }` results in `0` .
  #
  # The value handler modifies the result of the call of continuation in effect handlers of the handler.
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
    @handlers[@valh_id] = fun

    self
  end

  # sets effec handler `&fun` for `eff`
  #
  # @param [Effect<Arg, Ret>] eff
  #   the effect instance to be handled
  # @param [Proc<Arg, Ret => A>] fun
  #   a handler to handle `eff`;
  #   First argument of `&fun` is *continuation*, proc object
  #   to go back to the handled computation.
  # @return [Handler<A!{Effect<Arg, Ret>, e}, B!{e}>] itself updated with handling `Effect<Arg, Ret>`
  #
  # @example
  #   handler.on(Log) {|k, msg|
  #     puts "Logger: #{msg}"
  #     k[]
  #   }

  def on(eff, &fun)
    @handlers[eff.id] = fun

    self
  end

  # handles the computation.
  #
  # @param [Proc<(), A>] prc
  #   a thunk to be handled and returns `A`
  # @return [B]
  #   a value modified by value handler `Proc<A, B>` , or returned from the effect handler throwing continuation away
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
    co = Fiber.new &prc
    continue = nil
    rehandles = nil

    handle = ->(r) {
      if r.is_a? Eff
        if effh = @handlers[r.id]
          effh[continue, *r.args]
        else
          Fiber.yield Resend.new(r, continue)
        end
      elsif r.is_a? Resend
        eff = r.eff
        next_k = rehandles.(r.k)

        if effh = @handlers[eff.id]
          effh.(next_k, *eff.args)
        else
          Fiber.yield Resend.new(eff, next_k)
        end
      else
        @handlers[@valh_id].(r)
      end
    }

    rehandles = ->(k){
      newh = self.class.new
      def newh.add_handler id, h
        @handlers[id] = h
      end

      @handlers.each{|id, h|
        newh.add_handler id, h
      }

      class << newh
        undef add_handler
      end

      ->(*args) {
        continue[
          newh.run {
            k.(*args)
          }
        ]
      }
    }

    continue = ->(*arg) {
      handle.(co.resume(*arg))
    }

    continue.(nil)
  end
end
