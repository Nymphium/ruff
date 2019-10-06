# frozen_string_literal: true

module Util end

class Util::FnStack
  def initialize
    @queue = []
  end

  def enqueue(fn)
    @queue.push fn
  end

  def dequeue
    hd = @queue.pop
    hd[] unless hd.nil?
  end

  def cons(hd)
    queue_ = @queue.dup
    queue_.push hd
  end
end

class Util::Ref
  def initialize(v)
    @v = v
  end

  def get
    @v
  end

  def set(v_)
    @v = v_
  end
end

module Util::ADT
  def create
    Class.new do
      def initialize(v)
        @value = v
      end

      def get
        @value
      end
    end
  end

  module_function :create
end
