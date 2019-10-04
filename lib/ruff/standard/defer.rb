# frozen_string_literal: true

# `Defer` provides effects `Defer.eff` ,
# and the implementation to defer procedures .
#
# The module has an instance of `Instance` and provides its methods as module method.
# @see Standard::Defer::Instance
module Ruff::Standard::Defer
  class Instance
    # makes a new instance.
    def initialize
      @eff = Ruff.instance
    end

    # is a smart method to invoke the effect operation.
    # @param [Proc<(), ()>] prc
    #   is deferred, or "registerred", and called on the end of computation.
    # @return [()]
    def register(&prc)
      @eff.perform prc
    end

    # is a handler to interpret the effect invocation as registering a procedure.
    # Registerred procedures are run on the end of computation, by value handler.
    #
    # @param [Proc<(), A>!{Defer.eff, e}] th
    #  is a thunk returning `A` with the possibility to invoke effects, including `Defer.eff` .
    #
    # @return [A!{e}]
    #   returns `A` , without modification by value handler.
    #   But it still has the possibility to invoke effects(`e`).
    def with(&th)
      # This is a stack to store deferred procedures.
      procs = []

      Ruff.handler
          .on(@eff) do |k, prc|
        procs << prc
        k[]
      end
          .to do |_|
        # Like Go's defer functions, it crashes the thunk by reversed order.
        procs.reverse_each(&:[])
      end
          .run(&th)
    end

    # You can reimplement the handler using this effect instance.
    attr_reader :eff
  end

  # ---
  @inst = Instance.new
  @eff = @inst.eff

  # @see Ruff::Standard::Defer::Instance#register
  def register(&prc)
    @inst.register(&prc)
  end

  # @see Ruff::Standard::Defer::Instance#with
  def with(&th)
    @inst.with(&th)
  end

  module_function :register, :with

  # @see Ruff::Standard::Defer::Instance#eff
  attr_reader :eff
end
