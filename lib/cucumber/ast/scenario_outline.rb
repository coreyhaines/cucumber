module Cucumber
  module Ast
    class ScenarioOutline #:nodoc:
      include FeatureElement

      class ExamplesArray < Array #:nodoc:
        def accept(visitor)
          return if $cucumber_interrupted
          each do |examples|
            visitor.visit_examples(examples)
          end
        end
      end

      def initialize(background, comment, tags, keyword, name, line)
        @background, @comment, @tags, @keyword, @name, @line = background, comment, tags, keyword, name, line
        @steps = StepCollection.new
        @examples_array = ExamplesArray.new
      end

      def add_step(keyword, name, line)
        step = StepInvocation.new(self, keyword, name, line, [])
        @steps.add_step(step)
      end

      def add_examples(comment, keyword, name, line)
        examples = Examples.new(self, comment, keyword, name, line)
        @examples_array << examples
        examples
      end

      def accept(visitor)
        return if $cucumber_interrupted
        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(first_line_length))
        visitor.visit_steps(@steps)

        skip_invoke! if @background && @background.failed?
        visitor.visit_examples_array(@examples_array) unless @examples_array.empty?
      end

      def skip_invoke!
        @examples_array.each{|examples| examples.skip_invoke!}
        @feature.next_feature_element(self) do |next_one|
          next_one.skip_invoke!
        end
      end

      def step_invocations(cells)
        step_invocations = @steps.step_invocations_from_cells(cells)
        @background.step_collection(step_invocations)
      end

      def each_example_row(&proc)
        @examples_array.each do |examples|
          examples.each_example_row(&proc)
        end
      end

      def visit_scenario_name(visitor, row)
        visitor.visit_scenario_name(
          @feature.language.scenario_keyword,
          row.name, 
          file_colon_line(row.line), 
          source_indent(first_line_length)
        )
      end

      def to_sexp
        sexp = [:scenario_outline, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp += @examples_array.map{|e| e.to_sexp}
        sexp
      end
    end
  end
end
