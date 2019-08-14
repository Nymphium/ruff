module Ruff
  # This class provides an effect instance.
  class Effect
    # Each instance must be unique so they have unique id with UUID
    attr_reader :id

    # instaciates an effect setting _id_.
    # Example
    #   Log = Effect.new
    def initialize
      @id = SecureRandom.uuid
      @id.freeze
    end

    # sends an effect ID and its arguments to a NEAREST handler.
    # Example
    #   Log.perform "hello"
    def perform(*a)
      return Fiber.yield Throws::Eff.new(@id, a)
    end
  end
end
