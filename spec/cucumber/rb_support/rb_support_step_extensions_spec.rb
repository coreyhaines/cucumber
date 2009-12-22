require 'spec_helper'
require 'cucumber/rb_support/rb_step_extensions'

describe Cucumber::StepExtensions do
  context "no extensions registered" do
    it "returns the passed in args" do
      ext = Cucumber::StepExtensions.new
      ext.handle_arguments([:corey]).should == [:corey]
    end
  end

  context "no extensions requested" do
    before(:each) do
      module MyStepExtensions
        def self.reverse(arg)
          arg.reverse
        end

        def self.upcase(arg)
          arg.upcase
        end
      end

      Cucumber::StepExtensions.register_extension_module(MyStepExtensions)
    end
    it "returns the passed in args" do
      ext = Cucumber::StepExtensions.new
      ext.handle_arguments([:corey]).should == [:corey]
    end
  end

  context "one registered extensions module" do
    before(:each) do
      module MyStepExtensions
        def reverse(arg)
          arg.reverse
        end

        def upcase(arg)
          arg.upcase
        end
      end

      Cucumber::StepExtensions.register_extension_module(MyStepExtensions)
    end

    it "uses the registered extension" do
      extensions = Cucumber::StepExtensions.new(:reverse)
      extensions.handle_arguments(['hello']).should == ['olleh']
    end

    it "applies a single request extension method to all arguments" do
      se = Cucumber::StepExtensions.new(:reverse)
      se.handle_arguments(["hello", "Leon"]).should == ["olleh", "noeL"] 
    end

    it "handles different extension methods" do
      se = Cucumber::StepExtensions.new(:upcase)
      se.handle_arguments(["hello"]).should == ["HELLO"] 
    end

    it "applies desired extension method to the appropriate argument" do
      se = Cucumber::StepExtensions.new([:reverse, :upcase])
      se.handle_arguments(["hello", "Leon"]).should == ["olleh", "LEON"]
    end
  end

  context "two registered extension modules. 1... 2.. AH AH AH!" do
    before(:each) do
      module ReverseStepExtensions
        def self.reverse(arg)
          arg.reverse
        end
      end

      module CapitalStepExtensions
        def self.upcase(arg)
          arg.upcase
        end
      end

      Cucumber::StepExtensions.register_extension_module(ReverseStepExtensions,
                                                         CapitalStepExtensions)
    end

    it "handles specific calls to specific methods loaded" do
      extensions = Cucumber::StepExtensions.new(:reverse)
      extensions.handle_arguments(['hello']).should == ['olleh']
    end

    it 'handles calling different extension modules' do
      extensions = Cucumber::StepExtensions.new([:reverse, :upcase])
      extensions.handle_arguments(['hello', 'make_me_upper']).should == ['olleh', 'MAKE_ME_UPPER']
    end
  end
end