require 'gherkin'
require 'cucumber/ast/builder'

module Cucumber
  module Parser
    class NaturalLanguage
      KEYWORD_KEYS = %w{name native encoding feature background scenario scenario_outline examples given when then but}

      class << self
        def get(step_mother, i18n_language)
          languages[i18n_language] ||= new(step_mother, i18n_language)
        end

        def languages
          @languages ||= {}
        end
      end

      def initialize(step_mother, i18n_language)
        @i18n_language = i18n_language
        @keywords = Cucumber::LANGUAGES[i18n_language]
        raise "Language not supported: #{i18n_language.inspect}" if @keywords.nil?
        @keywords['grammar_name'] = @keywords['name'].gsub(/\s/, '')
        register_adverbs(step_mother) if step_mother
      end

      def register_adverbs(step_mother)
        adverbs = %w{given when then and but}.map{|keyword| @keywords[keyword].split('|').map{|w| w.gsub(/\s/, '')}}.flatten
        step_mother.register_adverbs(adverbs) if step_mother
      end

      def parse(source, path, filter)
        builder = Ast::Builder.new(path, filter)
        parser = Gherkin::Parser[@i18n_language].new(builder)
        parser.scan(source)
        feature = builder.ast
        feature.language = self if feature
        feature
      end

      def keywords(key, raw=false)
        return @keywords[key] if raw
        return nil unless @keywords[key]
        values = @keywords[key].split('|')
        values.map{|value| "'#{value}'"}.join(" / ")
      end

      def incomplete?
        KEYWORD_KEYS.detect{|key| @keywords[key].nil?}
      end

      def scenario_keyword
        @keywords['scenario'].split('|')[0] + ':'
      end

      def but_keywords
        @keywords['but'].split('|')
      end

      def and_keywords
        @keywords['and'].split('|')
      end
    end
  end
end
