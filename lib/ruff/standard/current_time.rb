module Ruff::Standard::CurrentTime
  class Instance
    def initialize
      @eff = Ruff.instance
    end

    def get
      @eff.perform
    end

    def with &th
      Ruff.handler.on(@eff){|k| k[Time.now]}.run &th
    end
  end

  # ---
  @inst = Instance.new

  def get
    @inst.get
  end

  def with &th
    @inst.with &th
  end

  module_function :get, :with
end

