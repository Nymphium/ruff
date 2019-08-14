require "ruff/version"
require "ruff/objects"
require "ruff/effect"
require "ruff/handler"
require 'securerandom'

module Ruff
  class << self
    # is alias for _Effect.new_
    # Example
    #   Log = Ruff.instance
    def instance
      Effect.new
    end

    # is alias for _Handler.new_
    # Example
    #   log_handler = Ruff.handler.on(Log){|msg, k|
    #     puts "Logger: #{msg}"
    #     k[]
    #   }
    def handler
      Handler.new
    end
  end
end
