# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ruff::Handler do
  describe '#to' do
    let(:log_effect) { Ruff::Effect.new }
    let(:handler) { Ruff.handler }

    it 'modifies the result of the computation' do
      result = handler.to { |x| x * 2 }.run { 5 }
      expect(result).to eq(10)
    end

    it 'interacts with effect handlers' do
      messages = []
      result = handler.on(log_effect) do |k, msg|
        messages << msg
        k[]
      end.to do |x|
        messages << "Final result: #{x}"
        messages.join(', ')
      end.run do
        log_effect.perform('msg1')
        log_effect.perform('msg2')
        100
      end
      expect(result).to eq('msg1, msg2, Final result: 100')
    end
  end

  describe '#on' do
    describe 'effect handler registration' do
      let(:log_effect) { Ruff::Effect.new }
      let(:handler) { Ruff.handler }

      it 'registers a handler for a given effect' do
        caught_message = nil
        handler.on(log_effect) do |k, msg|
          caught_message = msg
          k[]
        end.run do
          log_effect.perform('Test Message')
        end
        expect(caught_message).to eq('Test Message')
      end
    end

    describe 'subtyping' do
      let(:handler) { Ruff.handler }

      it 'chooses the most specific handler when subtyping is involved' do
        parent_eff = Ruff::Effect.new
        child_eff = Ruff::Effect << parent_eff

        handled_by = nil
        handler = Ruff.handler
                      .on(parent_eff) do |k, msg|
                        handled_by = "Parent: #{msg}"
                        k[]
                      end.on(child_eff) do |k, msg|
                        handled_by = "Child: #{msg}"
                        k[]
                      end

        handler.run { child_eff.perform('specific') }
        expect(handled_by).to eq('Child: specific')

        handler.run { parent_eff.perform('general') }
        expect(handled_by).to eq('Parent: general')
      end
    end
  end

  describe '#run' do
    describe 'handling computation' do
      let(:log_effect) { Ruff::Effect.new }
      let(:handler) { Ruff.handler }

      it 'handles a basic effect' do
        caught_message = nil
        handler.on(log_effect) do |k, msg|
          caught_message = msg
          k[]
        end.run do
          log_effect.perform('Basic Test')
        end
        expect(caught_message).to eq('Basic Test')
      end

      it 'returns the final value from the computation' do
        result = handler.on(log_effect) { |k, _| k[] }.run { 'Final Value' }
        expect(result).to eq('Final Value')
      end
    end

    describe 'layered handlers' do
      let(:log_effect) { Ruff::Effect.new }
      let(:handler) { Ruff.handler }

      it 'handles layered handlers (nested run blocks)' do
        double_effect = Ruff::Effect.new
        log_messages = []

        outer_handler = Ruff.handler.on(log_effect) do |k, msg|
          log_messages << "Outer Log: #{msg}"
          k[]
        end

        inner_handler = Ruff.handler.on(double_effect) do |k, val|
          log_messages << "Inner Double: #{val}"
          k[val * 2]
        end

        result = outer_handler.run do
          log_effect.perform('Starting outer')
          inner_handler.run do
            log_effect.perform('Starting inner') # This should be handled by outer_handler
            val = double_effect.perform(5)
            log_effect.perform("After double: #{val}")
            val + 1
          end
        end
        expect(result).to eq(11) # (5 * 2) + 1

        expect(log_messages).to eq([
                                     'Outer Log: Starting outer',
                                     'Outer Log: Starting inner',
                                     'Inner Double: 5',
                                     'Outer Log: After double: 10'
                                   ])
      end
    end

    describe 'unhandled effects' do
      let(:unhandled_effect) { Ruff::Effect.new }
      let(:handler) { Ruff.handler }

      it 'propagates unhandled effects as Resend' do
        caught_resend_eff = nil

        # Outer handler to catch the Resend
        outer_handler = Ruff.handler.on(unhandled_effect) do |k, msg|
          caught_resend_eff = msg
          k[]
        end

        # Inner computation that performs an unhandled effect
        outer_handler.run do
          unhandled_effect.perform('This should be resent')
        end

        expect(caught_resend_eff).to eq('This should be resent')
      end

      it 'allows an effect handler to perform another effect sequentially' do
        effect_a = Ruff::Effect.new
        effect_b = Ruff::Effect.new
        messages = []

        handler_a = Ruff.handler.on(effect_a) do |k, msg_a|
          messages << "Handled A: #{msg_a}"
          k[]
        end

        handler_b = Ruff.handler.on(effect_b) do |k, msg_b|
          messages << "Handled B: #{msg_b}"
          k[]
        end

        handler_b.run do
          handler_a.run do
            effect_a.perform('initial')
          end
          effect_b.perform('second')
          messages << 'Computation finished'
        end

        expect(messages).to eq([
                                 'Handled A: initial',
                                 'Handled B: second',
                                 'Computation finished'
                               ])
      end
    end
  end
end
