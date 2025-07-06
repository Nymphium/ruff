# frozen_string_literal: true

require 'spec_helper'
RSpec.describe Ruff::Standard do
  describe Ruff::Standard::Async do
    it 'handles async/await operations' do
      results = []
      described_class.with do
        task_a = described_class.async(proc do
          sleep(0.1) # Simulate some work
          results << 'Task A Done'
          10
        end)
        task_b = described_class.async(proc do
          results << 'Task B Started'
          described_class.yield
          results << 'Task B Resumed'
          20
        end)

        sum = described_class.await(task_a) + described_class.await(task_b)
        results << "Sum: #{sum}"
      end
      expect(results).to include('Task B Started', 'Task A Done', 'Task B Resumed', 'Sum: 30')
      expect(results.last).to eq('Sum: 30')
    end
  end

  describe Ruff::Standard::CurrentTime do
    it 'gets the current time' do
      time_before = Time.now
      result_time = nil
      described_class.with do
        result_time = described_class.get
      end
      time_after = Time.now
      expect(result_time).to be_between(time_before, time_after)
    end
  end

  describe Ruff::Standard::Defer do
    it 'executes registered procs at the end of the computation in reverse order' do
      execution_order = []
      described_class.with do
        execution_order << 'start'
        described_class.register { execution_order << 'defer 1' }
        execution_order << 'middle'
        described_class.register { execution_order << 'defer 2' }
        execution_order << 'end'
      end
      expect(execution_order).to eq(['start', 'middle', 'end', 'defer 2', 'defer 1'])
    end
  end

  describe Ruff::Standard::DelimCtrl do
    it 'handles delimited continuations with shift and reset' do
      output = []
      described_class.reset do
        output << 'hello'
        described_class.shift do |k|
          k.call
          output << '!'
        end
        output << 'world'
      end
      expect(output).to eq(['hello', 'world', '!'])
    end

    it 'captures and resumes continuation multiple times' do
      output = []
      described_class.reset do
        x = described_class.shift do |k|
          output << 'shifted'
          k.call(1) # Resume with 1
          output << 'shift_end'
          3 # Return value from shift if not resumed
        end
        output << "x is #{x}"
      end
      expect(output).to eq(['shifted', 'x is 1', 'shift_end'])
    end
  end

  describe Ruff::Standard::MeasureTime do
    it 'measures execution time of blocks' do
      results = nil
      described_class.with do
        described_class.measure 'first_task'
        sleep(0.01)
        described_class.measure 'second_task'
        sleep(0.02)
        42
      end.tap do |res|
        results = res
      end

      expect(results.first).to eq(42)
      expect(results.last[:label]).to eq('first_task')
      expect(results.last[:time]).to be_within(0.05).of(0.03)
      expect(results[1][:time]).to be_within(0.05).of(0.02)
      expect(results[1][:label]).to eq('second_task')
      expect(results[1][:time]).to be_within(0.05).of(0.02)
      # Time from first measure to second measure
    end
  end

  describe Ruff::Standard::State do
    it 'manages state with get, put, and modify' do
      final_state = nil
      described_class.with_init(0) do
        described_class.put(10)
        expect(described_class.get).to eq(10)
        described_class.modify { |s| s + 5 }
        expect(described_class.get).to eq(15)
        described_class.put(20)
        final_state = described_class.get
      end
      expect(final_state).to eq(20)
    end

    it 'uses nil as initial state with #with' do
      retrieved_state = nil
      described_class.with do
        retrieved_state = described_class.get
        described_class.put('hello')
      end
      expect(retrieved_state).to be_nil
    end
  end
end
