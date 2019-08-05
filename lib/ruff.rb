@counter = 0

class Eff
  attr_accessor :id, :args
  def initialize id, args
    @id = id; @args = args
  end
end

class Resend
  attr_accessor :eff, :k
  def initialize eff, k
    @eff = eff; @k = k
  end
end

def init
  c = Class.new do 
    attr_accessor :id
    def initialize id
      @id = id
    end

    def perform(*a)
      return Fiber.yield (Eff.new @id, a)
    end
  end

  c.new @counter+=1
end

class Handler
  def initialize
    @handlers = Hash.new
  end

  def on eff, prc
    @handlers[eff.id] = prc

    self
  end

  def run(&prc)
    co = Fiber.new &prc

    def handle co, r
      if r.is_a? Eff
        if effh = @handlers[r.id]
          effh[->(r){continue co, r}, *r.args]
        else
          Fiber.yield (Resend.new r, ->(r){continue co, r})
        end
      elsif r.is_a? Resend
        if effh = @handlers[r.eff.id]
          # FIXME: MAYBE WRONG implementation
          effh[->(r){->(k) {rehandles r, (->(r){continue co, r}), &k}}, *r.eff.args]
        else
          Fiber.yield (Resend.new r, ->(r){->(k) {rehandles r, (->(r){continue co, r}), &k}})
        end
      else
        r
      end
    end

    def rehandles arg, k, &prc
      newh = initialize

      @handlers.each{|id, proc|
        newh.on id, proc
      }

      k[newh.run(prc)]
    end

    def continue co, arg
      handle(co, co.resume(arg))
    end

    continue co, nil
  end
end

def handler
  Handler.new
end

