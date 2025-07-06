# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ruff::Effect do
  let(:log_effect) { described_class.new }

  describe '#initialize' do
    it 'initializes with a unique id' do
      expect(log_effect.id).to be_a(Object)
      expect(log_effect.id).not_to eq(described_class.new.id)
    end
  end

  describe 'subtyping' do
    let(:exception_effect) { described_class.new }
    let(:runtime_exception_effect) { described_class << exception_effect }

    it 'creates an effect with a subtyping relation' do
      expect(runtime_exception_effect).to be_an_instance_of(described_class)
      expect(runtime_exception_effect.id).to be_a(Object)
      expect(runtime_exception_effect.id.class.superclass).to eq(exception_effect.id.class)
    end

    describe 'handler behavior' do
      let(:exception_effect) { described_class.new }
      let(:runtime_exception_effect) { described_class << exception_effect }

      it 'a handler for the parent effect catches the child effect' do
        caught_message = nil
        handler = Ruff.handler
                      .on(exception_effect) do |k, msg|
                        caught_message = msg
                        k[]
                      end

        handler.run do
          runtime_exception_effect.perform('Runtime Error!')
        end

        expect(caught_message).to eq('Runtime Error!')
      end
    end

    describe 'multilevel handler behavior' do
      it 'handles multilevel subtyping correctly' do
        grandparent_effect = described_class.new
        parent_effect = described_class << grandparent_effect
        child_effect = described_class << parent_effect

        handled_by = nil
        handler =
          Ruff.handler
              .on(grandparent_effect) do |k, msg|
            handled_by = "Grandparent: #{msg}"
            k[]
          end.on(parent_effect) do |k, msg|
            handled_by = "Parent: #{msg}"
            k[]
          end.on(child_effect) do |k, msg|
            handled_by = "Child: #{msg}"
            k[]
          end.to do |_|
            handled_by
          end

        expect(handler.run do
          child_effect.perform('from child')
        end).to eq('Child: from child')
        expect(handler.run do
          parent_effect.perform('from parent')
        end).to eq('Parent: from parent')
        expect(handler.run do
          grandparent_effect.perform('from grandparent')
        end).to eq('Grandparent: from grandparent')
      end
    end
  end

  describe '#perform' do
    let(:log_effect) { described_class.new }

    it 'yields a Ruff::Throws::Eff object' do
      fiber = Fiber.new do
        log_effect.perform('hello')
      end
      eff_obj = fiber.resume

      expect(eff_obj).to be_an_instance_of(Ruff::Throws::Eff)
      expect(eff_obj.id).to eq(log_effect.id)
      expect(eff_obj.args).to eq(['hello'])
    end

    it 'raises FiberError if performed outside a handler' do
      expect { log_effect.perform('no handler') }.to raise_error(FiberError)
    end
  end
end
