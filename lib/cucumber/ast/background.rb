require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background #:nodoc:
      include FeatureElement
      attr_reader :feature_elements

      def initialize(comment, keyword, name, line)
        @comment, @keyword, @name, @line = comment, keyword, name, line
        @steps = StepCollection.new
      end

      def step_collectionXX(step_invocations)
        unless(@first_collection_created)
          @first_collection_created = true
          @steps.dup(step_invocations)
        else
          @steps.step_invocations(true).dup(step_invocations)
        end
      end

      def accept(visitor)
        return if $cucumber_interrupted
        visitor.visit_comment(@comment) unless @comment.nil? || @comment.empty?
        visitor.visit_background_name(@keyword, @name, file_colon_line(@line), source_indent(first_line_length)) unless @line.nil?
        visitor.step_mother.before(hook_context)
        visitor.visit_steps(@steps)
        @failed = @steps.detect{|step_invocation| step_invocation.exception}
        visitor.step_mother.after(hook_context) if @failed #|| @feature_elements.empty?
      end

      def accept_hook?(hook)
        if hook_context != self
          hook_context.accept_hook?(hook)
        else
          # We have no scenarios, just ask our feature
          @feature.accept_hook?(hook)
        end
      end

      def failed?
        @failed
      end

      def hook_context
        @feature.hook_context
      end
    end
  end
end
