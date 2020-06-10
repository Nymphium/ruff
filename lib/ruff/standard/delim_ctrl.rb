# frozen_string_literal: true

# `DelimCtrl` provides one-shot delimited control operators, `shift` and `reset`.
# @example
#   DelimCtrl.reset {
#     puts "hello"
#     DelimCtrl.shift { |k|
#       k.call
#       puts "!"
#     }
#
#     puts "world"
#   }
#   # ==>
#   #   hello
#   #   world
#   #   !
module Ruff::Standard::DelimCtrl
  # prompt stack
  @stack = []

  # delimits a continuation
  # @param [Proc<(), A>] th
  #   is a thunk. In this thunk `shift` captures a continuation delimited with the thunk.
  def reset(&th)
    eff = Ruff::Effect.new
    @stack.push eff

    ret = Ruff.handler
              .on(eff) do |k, f|
                f.call(k)
              end
              .run(&th)

    @stack.pop
    ret
  end

  # captures a continuation.
  # @param [Proc<Proc<C, A>, A/B>] k
  #  is a continuation.
  def shift(&k)
    # fetch nearmost prompt
    top = @stack.last
    top.perform(k)
  end

  module_function :reset, :shift
end
