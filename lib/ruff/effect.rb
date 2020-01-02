# frozen_string_literal: true

# This class provides an effect instance.
class Ruff::Effect
  # Each instance must be unique so they have unique id with an annonymous class instance.
  #
  # The class instance may have subtyping relation.
  # @see <<
  attr_reader :id

  # instaciates an effect setting `id`.
  # @return [Effect<Arg, Ret>]
  # @example
  #   Log = Effect.new #==> it _might_ be Effect<string, nil>
  def initialize
    @id = Class.new.new
  end

  # instanciates an effect, which has an relation `self <: parent`
  # from the subtyping of `id` object.
  #
  # @param [Effect<Arg, Ret>] parent
  # @return [Effect<Arg, Ret>] with an relation `it <: parent`
  #
  # @example
  #   Exception = Ruff::Effect.new
  #   RuntimeException = Ruff::Effect << Exception
  #
  #   Ruff::Handler.new
  #     .on(Exception){
  #       puts "catch"
  #     }
  #     .run {
  #       RuntimeException.perform
  #     }
  #   # ==> prints "catch"
  def self.<<(parent)
    inst = new
    parent_id = parent.instance_variable_get('@id')
    inst.instance_variable_set('@id', (Class.new parent_id.class).new)
    inst
  end

  # sends an effect ID and its arguments to a nearmost handler.
  #
  # @param [Arg] a of the object `Effect<Arg, Ret>`
  # @return [Ret] of the object `Effect<Arg, Ret>`
  #
  # @example
  #   Log.perform "hello"
  def perform(*a)
    Fiber.yield Ruff::Throws::Eff.new(@id, a)
  end
end
