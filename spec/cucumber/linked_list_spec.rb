require File.dirname(__FILE__) + '/../spec_helper'
require 'cucumber/linked_list'

module Cucumber
  describe LinkedList do
    it "should have a first" do
      l = LinkedList.new
      l << "a"
      l.first_node.should == "a"
    end

    it "should have a first pointing to a next" do
      l = LinkedList.new
      l << "a"
      l << "b"
      l.first_node.next_node.should == "b"
    end

    it "should have a last pointing to a prev" do
      l = LinkedList.new
      l << "a"
      l << "b"
      l.last_node.prev_node.should == "a"
    end
    
    it "should be possible to reassign pointer" do
      l1 = LinkedList.new
      l1 << "a"
      l1 << "b"

      l2 = LinkedList.new
      l2 << "c"
      l2 << "d"
      
      l1.last_node.next_node = l2.first_node
      
      l1.to_a.should == %w{a b c d}
    end
  end
end