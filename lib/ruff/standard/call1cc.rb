# frozen_string_literal: true

# `Call1cc` provides call-with-oneshot-continuation.
# The continuation can be run in the `context`.
#
# @example
#   Call1cc.context do
#     divfail = lambda { |l, default|
#       Call1cc.run {|k|
#         l.map{|e|
#           if e.zero?
#             k.call(default)
#           else
#             e / 2
#           end
#         }
#       }
#     }
#
#     pp divfail.call([1, 3, 5], [1])
#     # ==> [0, 1, 2]
#     puts '---'
#     pp divfail.call([1, 0, 5], [1])
#     # ==> [1]
#   end

module Ruff::Standard::Call1cc
  # call stack
  @stack = []

  def context(&prc)
    p = Ruff.instance
    @stack.push p

    ret = Ruff.handler
              .on(p) do |k, v|
      k.call(v)
    end
              .run(&prc)

    @stack.pop
    ret
  end

  def run(&f)
    top = @stack.first
    Ruff.handler
        .on(top) do |_, v|
      # abort the rest of computation from calling the continuation
      top.perform(v)
    end.run do
      f.call(->(v) { top.perform(v) })
    end
  end

  module_function :context, :run
end
