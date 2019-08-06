module Ruff
  class Effect
    attr_accessor :id
    def initialize
      @id = SecureRandom.uuid
    end

    def perform(*a)
      return Fiber.yield Eff.new(@id, a)
    end
  end
end
