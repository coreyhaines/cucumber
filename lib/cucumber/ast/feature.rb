module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature #:nodoc:
      attr_accessor :language
      attr_writer :features
      attr_reader :name

      def initialize(file, comment, tag_names, name)
        @file, @comment, @tags, @name = file, comment, tags_for(tag_names), name.strip
        @feature_elements = []
        set_default_background
      end

      def set_background(comment, keyword, name, line)
        @background = Background.new(comment, keyword, name, line)
        @background.feature = self
        @background
      end

      def add_scenario(comment, tag_names, keyword, name, line)
        add_feature_element(Scenario.new(@background, comment, tags_for(tag_names), keyword, name, line))
      end

      def add_scenario_outline(comment, tag_names, keyword, name, line)
        add_feature_element(ScenarioOutline.new(@background, comment, tags_for(tag_names), keyword, name, line))
      end

      def accept(visitor)
        return if $cucumber_interrupted
        visitor.visit_comment(@comment) unless @comment.nil? || @comment.empty?
        visitor.visit_tags(@tags) unless @tags.nil?
        visitor.visit_feature_name(@name)
        visitor.visit_background(@background)
        @feature_elements.each do |feature_element|
          visitor.visit_feature_element(feature_element)
        end
      end

      def hook_context
        @feature_elements.first || @background
      end

      def accept_hook?(hook)
        @tags.accept_hook?(hook)
      end

      def next_feature_element(feature_element, &proc)
        index = @feature_elements.index(feature_element)
        next_one = @feature_elements[index+1]
        proc.call(next_one) if next_one
      end

      def backtrace_line(step_name, line)
        "#{file_colon_line(line)}:in `#{step_name}'"
      end

      def file_colon_line(line)
        "#{@file}:#{line}"
      end

      def tag_count(tag)
        if @tags.respond_to?(:count)
          @tags.count(tag) # 1.9
        else
          @tags.select{|t| t == tag}.length  # 1.8
        end
      end

      def feature_and_children_tag_count(tag)
        children_tag_count = @feature_elements.inject(0){|count, feature_element| count += feature_element.tag_count(tag)}
        children_tag_count + tag_count(tag)
      end

      def short_name
        first_line = name.split(/\n/)[0]
        if first_line =~ /#{language.keywords('feature', true)}:(.*)/
          $1.strip
        else
          first_line
        end
      end

      private

      def tags_for(tag_names)
        tag_names ? Tags.new(tag_names) : nil
      end

      def set_default_background
        set_background(nil, nil, nil, nil)
      end
      
      def add_feature_element(feature_element)
        feature_element.feature = self
        @feature_elements << feature_element
        feature_element
      end

    end
  end
end
