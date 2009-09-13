require 'cucumber/ast'

module Cucumber
  module Ast
    # TODO: use the filter so we don't add more than needed.
    class Builder
      attr_reader :ast

      def initialize(path, filter)
        @path = path
      end

      def tag(tag_name, line)
        @tag_names ||= []
        @tag_names << tag_name
      end

      def comment(comment, line)
        @comment = Comment.new(comment)
      end

      def feature(keyword, name_and_narrative, line)
        @ast = Feature.new(@path, @comment, @tag_names, name_and_narrative)
        @comment = @tag_names = nil
        @ast
      end

      def background(keyword, name, line)
        @feature_element = @ast.set_background(@comment, keyword, name, line)
        @comment = @tag_names = nil
        @feature_element
      end

      def scenario(keyword, name, line)
        @feature_element = @ast.add_scenario(@comment, @tag_names, keyword, name, line)
        @comment = @tag_names = nil
        @feature_element
      end

      def scenario_outline(keyword, name, line)
        @feature_element = @ast.add_scenario_outline(@comment, @tag_names, keyword, name, line)
        @comment = @tag_names = nil
        @feature_element
      end

      def step(keyword, name, line)
        @step = @feature_element.add_step(keyword, name, line)
      end

      def examples(keyword, name, line)
        @examples = @feature_element.add_examples(@comment, keyword, name, line)
        @comment = @tag_names = nil
        @examples
      end

      def table(raw, line)
        if(@examples)
          @examples.set_table(raw, line)
        else
        end
      end
      
      def py_string(string, line)
        @step.set_multiline_string(string, line)
      end
    end
  end
end