# frozen_string_literal: true

module Ruff::Standard::State
  class Instance
    def initialize
      @get = Ruff.instance
      @modify = Ruff.instance
    end

    def get
      @get.perform
    end

    def modify(&fn)
      @modify.perform fn
    end

    def put(s)
      @modify.perform ->(_) { s }
    end

    def with_init(init, &task)
      state = init

      Ruff.handler
          .on(@modify) do |k, fn|
        state = fn[state]
        k[nil]
      end
          .on(@get) do |k|
        k[state]
      end
          .run &task
    end

    def with(&task)
      with_init(nil, &task)
    end
  end

  # ---
  @inst = Instance.new

  def get
    @inst.get
  end

  def modify(&fn)
    @inst.modify &fn
  end

  def put(s)
    @inst.put s
  end

  def with_init(init, &task)
    @inst.with_init init, &task
  end

  def with(&task)
    @inst.with &task
  end

  module_function :get, :put, :modify, :with, :with_init
end
