module Ruff
  # In algebraic effects, handler is an first-class object.
  class Handler
    # makes a new handler, internally having fresh empty hash.
    # This is a effect-handler store and when handliong it is looked up.
    # @example
    #   handler = Handler.new
    def initialize
      @handlers = Hash.new
    end

    # sets effec handler `&prc` for `eff`
    #
    # @param [Effect<Arg, Ret>] eff
    #   the effect instance to be handled
    # @param [Proc<Arg, Ret => A>] prc
    #   a handler to handle `eff`;
    #   last argument of `&prc` is *continuation*, proc object
    #   to go back to the handled computation.
    # @return [Handler{Effect<Arg, Ret>, e}] itself updated with handling `Effect<Arg, Ret>`
    #
    # @example
    #   handler.on(Log) {|msg, k|
    #     puts "Logger: #{msg}"
    #     k[]
    #   }
    def on(eff, &prc)
      @handlers[eff.id] = prc

      self
    end

    # @param [Proc<(), T>]
    # @return [T]
    #
    # handles the computation.
    #
    # @example
    #   handler.run {
    #     Log.perform "hello"
    #   }
    #
    # @example `handler` can be layered.
    #   handler.run {
    #     Handler.new
    #       .on(Double){|v, k|
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
        if r.is_a? Throws::Eff
          if effh = @handlers[r.id]
            effh[continue, *r.args]
          else
            Fiber.yield (Throws::Resend.new r, continue)
          end
        elsif r.is_a? Throws::Resend
          if effh = @handlers[r.eff.id]
            effh[rehandles[r.k], *r.eff.args]
          else
            Fiber.yield (Throws::Resend.new r, rehandles[r.k])
          end
        else
          r
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
              k[*args]
            }
          ]
        }
      }

      continue = ->(*arg) {
        handle[co.resume(*arg)]
      }

      continue[nil]
    end
  end
end
