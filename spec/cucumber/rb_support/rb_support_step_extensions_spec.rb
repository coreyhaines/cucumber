require 'spec_helper'
require 'cucumber/rb_support/rb_step_extensions'

describe Cucumber::StepExtensions do
  context "no extensions registered" do
    it "returns the passed in args" do
      Cucumber::StepExtensions.handle_arguments([:corey]).should == [:corey]
    end
  end
end