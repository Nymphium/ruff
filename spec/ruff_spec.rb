# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ruff do
  it 'has a version number' do
    expect(Ruff::VERSION).not_to be_nil
  end

  describe '.instance' do
    it 'is an alias for Effect.new' do
      expect(described_class.instance).to be_an_instance_of(Ruff::Effect)
    end
  end

  describe '.handler' do
    it 'is an alias for Handler.new' do
      expect(described_class.handler).to be_an_instance_of(Ruff::Handler)
    end
  end
end
