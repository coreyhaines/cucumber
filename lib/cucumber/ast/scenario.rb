require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Scenario #:nodoc:
      include FeatureElement
      
      attr_reader :name, :line
      
      def initialize(background, comment, tags, keyword, name, line)
        @background, @comment, @tags, @keyword, @name, @line = background, comment, tags, keyword, name, line
        @steps = StepCollection.new
      end

      def accept(visitor)
        return if $cucumber_interrupted
        
        with_visitor(visitor) do
          visitor.visit_comment(@comment) unless @comment.nil? || @comment.empty?
          visitor.visit_tags(@tags) if @tags
          visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(first_line_length))

          skip_invoke! if @background.failed?
          visitor.step_mother.before_and_after(self, skip_hooks?) do
            skip_invoke! if failed?
            visitor.visit_steps(@steps)
          end
          @executed = true
        end
      end

      # Returns true if one or more steps failed
      def failed?
        @steps.failed? || !!@exception
      end
      
      def fail!(exception)
        @exception = exception
        @current_visitor.visit_exception(@exception, :failed)
      end

      # Returns true if all steps passed
      def passed?
        !failed?
      end

      # Returns the first exception (if any)
      def exception
        @exception || @steps.exception
      end

      # Returns the status
      def status
        return :failed if @exception
        @steps.status
      end

      def skip_invoke!
        @steps.each{|step_invocation| step_invocation.skip_invoke!}
        @feature.next_feature_element(self) do |next_one|
          next_one.skip_invoke!
        end
      end

      def to_sexp
        sexp = [:scenario, @line, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp
      end
      
      private
      
      def with_visitor(visitor)
        @current_visitor = visitor
        yield
        @current_visitor = nil
      end
      
      def skip_hooks?
        @background.failed? || @executed
      end
    end
  end
end
