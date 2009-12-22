require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/rb_support/rb_transforms'


describe "Global method for adding explicit transforms" do
  module MyTransforms
    def foo(bar)
      "called with #{bar}"
    end
  end

  it "adds my methods to Cucumber::RbSupport::Transforms" do
    ExplicitTransforms(MyTransforms)
    Cucumber::RbSupport::Transforms.foo('param').should == 'called with param'
  end
end


describe Cucumber::RbSupport::ExplicitTransforms do
  module MyTransforms
    def uppercase(this)
      this.upcase
    end
    def reverse(this)
      this.reverse
    end
  end
  it "accepts the list of transforms in initialize" do
    transforms = Cucumber::RbSupport::ExplicitTransforms.new [:foo, :bar]
  end
  it "transforms a single argument" do
    ExplicitTransforms(MyTransforms)
    transforms = Cucumber::RbSupport::ExplicitTransforms.new :uppercase
    args = transforms.transform(['corey'])
    args[0].should == 'COREY'
  end
  it "transforms multiple arguments" do
    ExplicitTransforms(MyTransforms)
    transforms = Cucumber::RbSupport::ExplicitTransforms.new [:uppercase, :uppercase]
    args = transforms.transform(['corey', 'sarah'])
    args[0].should == 'COREY'
    args[1].should == 'SARAH'
  end
  it "applies a single transform to all arguments" do
    ExplicitTransforms(MyTransforms)
    transforms = Cucumber::RbSupport::ExplicitTransforms.new :uppercase
    args = transforms.transform(['corey', 'sarah'])
    args[0].should == 'COREY'
    args[1].should == 'SARAH'
  end
  it "transforms with different transforms" do
    ExplicitTransforms(MyTransforms)
    transforms = Cucumber::RbSupport::ExplicitTransforms.new [:uppercase, :reverse]
    args = transforms.transform(['corey', 'sarah'])
    args[0].should == 'COREY'
    args[1].should == 'haras'
  end
  it "does not transform if nil is given" do
    ExplicitTransforms(MyTransforms)
    transforms = Cucumber::RbSupport::ExplicitTransforms.new [nil, :reverse]
    args = transforms.transform(['corey', 'sarah'])
    args[0].should == 'corey'
    args[1].should == 'haras'
  end
  it "returns args if no transforms" do
    ExplicitTransforms(MyTransforms)
    transforms = Cucumber::RbSupport::ExplicitTransforms.new nil
    args = transforms.transform(['corey', 'sarah'])
    args[0].should == 'corey'
    args[1].should == 'sarah'
  end
end
