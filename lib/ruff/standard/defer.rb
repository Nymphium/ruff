# frozen_string_literal: true

module Ruff::Standard::Defer
  class Instance
    def initialize
      @eff = Ruff.instance
    end

    def register(&prc)
      @eff.perform prc
    end

    def with(&th)
      procs = []

      Ruff.handler
          .on(@eff) do |k, prc|
        procs << prc
        k[]
      end
          .to do |_|
        procs.reverse_each(&:[])
      end
          .run &th
    end
  end

  # ---
  @inst = Instance.new

  def register(&prc)
    @inst.register &prc
  end

  def with(&th)
    @inst.with &th
  end

  module_function :register, :with
end
