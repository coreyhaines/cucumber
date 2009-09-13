module Cucumber
  module Ast
    # Holds an Array of Step or StepDefinition
    # TODO: Make a doubly linked list would be cleaner
    class StepCollection #:nodoc:
      include Enumerable
      
      def initialize
        @steps = []
      end

      def add_step(feature_element, keyword, name, line)
        @previous = StepInvocation.new(@previous, feature_element, keyword, name, line, [])
        _add_step(@previous)
      end

      def from_cells(cells)
        steps = StepCollection.new
        previous_cell_step = nil
        @steps.each do |step| 
          previous_cell_step = step.from_cells(previous_cell_step, cells)
          steps._add_step(previous_cell_step)
        end
        steps
      end

      def _add_step(step)
        @steps << step
        step
      end

      def accept(visitor, &proc)
        return if $cucumber_interrupted
        @steps.each do |step|
          visitor.visit_step(step) if proc.nil? || proc.call(step)
        end
      end

      # def step_invocations(background = false)
      #   StepCollection.new(@steps.map{ |step| 
      #     i = step.step_invocation
      #     i.background = background
      #     i
      #   })
      # end

      # # Duplicates this instance and adds +step_invocations+ to the end
      # def dup(step_invocations = [])
      #   StepCollection.new(@steps + step_invocations)
      # end

      def each(&proc)
        @steps.each(&proc)
      end

      def empty?
        @steps.empty?
      end

      def max_line_length(feature_element)
        lengths = (@steps + [feature_element]).map{|e| e.text_length}
        lengths.max
      end

      def exception
        @exception ||= ((failed = @steps.detect {|step| step.exception}) && failed.exception)
      end

      def failed?
        status == :failed
      end

      def passed?
        status == :passed
      end
      
      def status
        @steps.each{|step| return step.status if step.status != :passed}
        :passed
      end
    end
  end
end
