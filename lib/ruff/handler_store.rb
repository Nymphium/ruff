# frozen_string_literal: true

class Ruff::HandlerStore
  def initialize
    @handler = {}
  end

  def []=(r, e)
    @handler[r.id] = e
  end

  def [](eff)
    fns = @handler.filter do |effky, _fun|
      eff.id.is_a? effky.class
    end

    return fns.min_by { |effky, _| effky.class }[1] unless fns.empty?

    nil
  end
end
