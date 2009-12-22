require 'spec_helper'
require 'cucumber/rb_support/rb_step_extensions'

describe Cucumber::StepExtensions do
  context "no extensions registered" do
    it "returns the passed in args" do
      Cucumber::StepExtensions.handle_arguments(nil, [:corey]).should == [:corey]
    end
  end

  context "one registered extensions module" do
    before(:each) do
      module MyStepExtensions
        def self.reverse(arg)
          arg.reverse
        end
      end

      Cucumber::StepExtensions.register_extension_module(:arg_transform, MyStepExtensions)
    end

    it "uses the registered extension" do
      Cucumber::StepExtensions.handle_arguments(nil, ['hello']).should == ['olleh']
    end
  end
end