# frozen_string_literal: true

# `CurrentTime` provides an effect `CurrentTime.eff` and the implementation returning `Time.now` .
#
# The module has an instance of `Instance` and provides its methods as module method.
# @see Standard::CurrentTime::Instance
module Ruff::Standard::CurrentTime
  class Instance
    # makes a new instance.
    def initialize
      @eff = Ruff.instance
    end

    # is a smart method to invoke the effect operation.
    # @return [Time]
    #   with `with` , returns `Time.now`
    def get
      @eff.perform
    end

    # is a handler to interpret the effect invokation as requesting the current time.
    # This handler receives the *request* and returns current time.
    #
    # @param [Proc<(), A>!{CurrentTime.eff, e}] th
    #  is a thunk returning `A` with the possibility to invoke effects,
    #  including `CurrentTime.eff` .
    #
    # @return [A!{e}]
    #   returns `A` , without modification by value handler.
    #   But it still has the possibility to invoke effects(`e`).
    def with(&th)
      Ruff.handler.on(@eff) { |k| k[Time.now] }.run(&th)
    end

    # You can reimplement the handler using this effect instance.
    attr_reader :eff
  end

  # ---
  @inst = Instance.new
  @eff = @inst.eff

  # @see Ruff::Standard::CurrentTime::Instance#get
  def get
    @inst.get
  end

  # @see Ruff::Standard::CurrentTime::Instance#with
  def with(&th)
    @inst.with(&th)
  end

  module_function :get, :with

  # @see Ruff::Standard::CurrentTime::Instance#eff
  attr_reader :eff
end
