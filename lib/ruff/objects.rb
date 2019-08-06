module Ruff
  class Eff
    attr_accessor :id, :args
    def initialize(id, args)
      @id = id; @args = args
    end
  end

  class Resend
    attr_accessor :eff, :k
    def initialize(eff, k)
      @eff = eff; @k = k
    end
  end
end
