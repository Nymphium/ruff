# frozen_string_literal: true

# `MeasureTime` provides effects `MeasureTime.eff` ,
# and the implementation to measure and report execution time .
#
# The module has an instance of `Instance` and provides its methods as module method.
# @see Standard::MeasureTime::Instance
#
# @example
#   MeasureTime.with {
#     MeasureTime.measure 'one'
#     sleep 1
#     MeasureTime.measure 'two'
#     sleep 0.1
#
#     return 0
#   }
#   #==> [0, {:label=>"two", :time=>0.1}, {:label=>"one", :time=>1.1}]
module Ruff::Standard::MeasureTime
  class Instance
    # makes a new instance.
    def initialize
      @eff = Ruff.instance
      @handler = Ruff.handler
      @handler.on(@eff) do |k, label|
        t1 = Time.now
        result = k[]
        t2 = Time.now
        result + [{ label: label, time: t2 - t1 }]
      end
      @handler.to { |x| [x] }
    end

    # is a smart method to invoke the effect operation.
    # @param [string] label
    #   is the label of the measurement.
    # @return [()]
    def measure(label)
      @eff.perform(label)
    end

    # is a handler to interpret the effect invocation as measuring computation time.
    #
    # @param [Proc<(), A!{MeasureTime.eff, e}>] th
    #  is a thunk returning `A` with the possibility to invoke effects,
    #  including `MeasureTime.eff` .
    #
    # @return [[A, ...{ label: string, time: float }]!{e}]
    #   returns list. the first is the result `A`, and the rest is the measurement results.
    #   It still has the possibility to invoke effects(`e`).
    def with(&th)
      @handler.run(&th)
    end

    # You can reimplement the handler using this effect instance.
    attr_reader :eff
  end

  # ---
  @inst = Instance.new
  @eff = @inst.eff

  # @see Ruff::Standard::MeasureTime::Instance#measure
  def measure(label)
    @inst.measure(label)
  end

  # @see Ruff::Standard::MeasureTime::Instance#with
  def with(&th)
    @inst.with(&th)
  end

  module_function :measure, :with

  # @see Ruff::Standard::MeasureTime::Instance#eff
  attr_reader :eff
end
