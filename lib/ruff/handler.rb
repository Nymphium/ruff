module Ruff
  class Handler
    def initialize
      @handlers = Hash.new
    end

    def on(eff, prc)
      @handlers[eff.id] = prc

      self
    end

    def run(&prc)
      co = Fiber.new &prc
      continue = nil
      rehandles = nil

      handle = ->(r) {
        if r.is_a? Eff
          if effh = @handlers[r.id]
            effh[continue, *r.args]
          else
            Fiber.yield (Resend.new r, continue)
          end
        elsif r.is_a? Resend
          if effh = @handlers[r.eff.id]
            effh[rehandles[r.k], *r.eff.args]
          else
            Fiber.yield (Resend.new r, rehandles[r.k])
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

        ->(*args) {
          newh.run {
            k[*args]
          }
        }
      }

      continue = ->(*arg) {
        handle[co.resume(*arg)]
      }

      continue[nil]
    end
  end
end
