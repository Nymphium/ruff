# frozen_string_literal: true

# This class provides an effect instance.
class Ruff::Effect
  # Each instance must be unique so they have unique id with UUID
  attr_reader :id

  # instaciates an effect setting `id`.
  # @return [Effect<Arg, Ret>]
  # @example
  #   Log = Effect.new #==> it _might_ be Effect<string, nil>
  def initialize(parent = nil)
    @id = if parent
            (Class.new parent.id.class).new
          else
            Class.new.new
          end
  end

  # sends an effect ID and its arguments to a nearmost handler.
  # @param [Arg] a of the object `Effect<Arg, Ret>`
  # @return [Ret] of the object `Effect<Arg, Ret>`
  # @example
  #   Log.perform "hello"
  def perform(*a)
    Fiber.yield Ruff::Throws::Eff.new(@id, a)
  end
end
