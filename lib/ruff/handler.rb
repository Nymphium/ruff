module Ruff

  # In algebraic effects, handler is an first-class object.
  class Handler

    # makes a new handler internally generating empty hash.
    # This is a effect-handler store and when handliong it is looked up.
    # Example
    #   handler = Handler.new
    def initialize
      @handlers = Hash.new
    end

    # sets effec handler _prc_ for _eff_
    #
    # Last argument of _prc_ is *continuation*, proc object
    # to go back to the handled computation.
    # Example
    #   handler.on(Log) {|msg, k|
    #     puts "Logger: #{msg}"
    #     k[]
    #   }
    def on(eff, &prc)
      @handlers[eff.id] = prc

      self
    end

    # handles the computation.
    # Example
    #   handler.run {
    #     Log.perform "hello"
    #   }
    #
    # _handler_ can be layered.
    # Example
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
