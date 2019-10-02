# frozen_string_literal: true

require 'ruff/version'
require 'ruff/objects'
require 'ruff/effect'
require 'ruff/handler'
require 'securerandom'

module Ruff
  class << self
    # is alias for `Effect.new`
    # @see Effect.initialize Effect.initialize
    #
    # @example
    #   Log = Ruff.instance # === Ruff::Effect.new
    def instance
      Effect.new
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
