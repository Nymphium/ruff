# frozen_string_literal: true

# `Ruff::Standard` provides several pre-defined effect handlers modules.
# Each module provides `Instance` class to instantiate and handle the indivisual effect instances.
# @example
#   include Ruff::Standard
#
#   state1 = State::Instance.new
#   state2 = State::Instance.new
#
#   state1.with_init(3) {
#   state2.with_init(4) {
#     state2.modify {|s| s + state1.get }
#
#     puts state1.get #==> 3
#     puts state2.get #==> 7
#   }}
#
module Ruff::Standard end

require 'ruff'
require 'ruff/standard/current_time'
require 'ruff/standard/measure_time'
require 'ruff/standard/defer'
require 'ruff/standard/state'
require 'ruff/standard/async'
require 'ruff/standard/call1cc'
