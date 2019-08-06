require "ruff/version"
require "ruff/objects"
require "ruff/effect"
require "ruff/handler"
require 'securerandom'

module Ruff
  class << self
    def instance
      Effect.new
    end

    def handler
      Handler.new
    end
  end
end
