# frozen_string_literal: true

module Ruff
  class << self
    require 'ruff/version'
    require 'ruff/objects'
    require 'ruff/effect'
    require 'ruff/handler'
    require 'securerandom'

    # is alias for `Effect.new`
    # @see Effect.initialize Effect.initialize
    #
    # @example
    #   Log = Ruff.instance #==> Ruff::Effect.new
    def instance(parent = nil)
      Effect.new(parent)
    end

    # is alias for `Handler.new`
    # @see Handler.initialize Handler.initialize
    #
    # @example
    #   log_handler = Ruff.handler.on(Log){|msg, k|
    #     puts "Logger: #{msg}"
    #     k[]
    #   }
    def handler
      Handler.new
    end
  end
end
