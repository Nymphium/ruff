# frozen_string_literal: true

require 'ruff'

Double = Ruff.instance
Triple = Ruff.instance
Log = Ruff.instance

h1 = Ruff.handler
         .on(Double) { |k, v| k[v * 2] }
         .on(Triple) { |k, v| k[v * 3] }

h2 = Ruff.handler.on(Log) do |k, msg|
  puts "logger: #{msg}"
  k[]
end

h1.run do
  h2.run do
    v = Double.perform 2
    Log.perform(v + 2)
    puts Triple.perform 3
  end
end
