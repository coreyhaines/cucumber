Feature: transform
  In order to maintain modularity within step definitions
  As a step definition editor
  I want to register explicit transforms for step definition arguments.

  Background:         
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
      """
      module MyTransforms
        def fixnum(string)
          string.scan(/\d/).join.to_i
        end
        def symbol(string)
          string.to_sym
        end
      end
      ExplicitTransforms(MyTransforms)

      Then /^I should transform '(\d+)' to an Integer$/,
            :transform => :fixnum do |integer|
        integer.should be_kind_of(Integer)
      end

      Then /^I should transform '(\w+)' to a Symbol$/,
            :transform => :symbol do |symbol|
        symbol.should be_kind_of(Symbol)
      end

      Then /^I should not transform '(\d+)' to an Integer$/ do |string|
        string.should be_kind_of(String)
      end

      Then /^I should transform '(\d+)' to an Integer and '(\w+)' to a Symbol$/,
            :transform => [:fixnum, :symbol] do |integer, symbol|
        integer.should be_kind_of(Integer)
        symbol.should be_kind_of(Symbol)
      end

      Then /^I should not transform '(\d+)' to an Integer, but transform '(\w+)' to a Symbol$/,
            :transform => [nil, :symbol] do |string, symbol|
        string.should be_kind_of(String)
        symbol.should be_kind_of(Symbol)
      end

      Then /^I should transform all these '(\d+)' '(\d+)' to an Integer$/,
           :transform => :fixnum do |int1, int2|
        int1.should be_kind_of(Integer)
        int2.should be_kind_of(Integer)
      end
      """

  Scenario: Transforming single arguments
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: transform integer
          Then I should transform '10' to an Integer

        Scenario: transform symbol
          Then I should transform 'abc' to a Symbol

        Scenario: transform without matches
          Then I should not transform '10' to an Integer
      """
    When I run cucumber -s features
    Then it should pass with
      """
      Feature: Step argument transformations

        Scenario: transform integer
          Then I should transform '10' to an Integer

        Scenario: transform symbol
          Then I should transform 'abc' to a Symbol

        Scenario: transform without matches
          Then I should not transform '10' to an Integer

      3 scenarios (3 passed)
      3 steps (3 passed)

      """

  Scenario: Transforming two arguments
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: transform multiple arguments
          Then I should transform '10' to an Integer and 'abc' to a Symbol

        Scenario: nil transform for first
          Then I should not transform '20' to an Integer, but transform 'corey' to a Symbol

        Scenario: transform all with single transform
          Then I should transform all these '5' '10' to an Integer
      """
    When I run cucumber -s features
    Then it should pass with
      """
      Feature: Step argument transformations

        Scenario: transform multiple arguments
          Then I should transform '10' to an Integer and 'abc' to a Symbol

        Scenario: nil transform for first
          Then I should not transform '20' to an Integer, but transform 'corey' to a Symbol

        Scenario: transform all with single transform
          Then I should transform all these '5' '10' to an Integer

      3 scenarios (3 passed)
      3 steps (3 passed)

      """
