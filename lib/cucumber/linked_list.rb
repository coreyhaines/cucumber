module Cucumber
  class LinkedList
    include Enumerable
    attr_accessor :first_node, :last_node
    
    def <<(node)
      if @first_node.nil?
        node.extend(Node)
        @first_node = @last_node = node
      else
        @last_node.next_node = node
      end
      @last_node = node
    end

    def each(&proc)
      node = @first_node
      loop do
        yield node
        node = node.next_node
        break if node.nil?
      end
    end

    module Node
      attr_reader :next_node, :prev_node
      
      def next_node=(node)
        @next_node = node
        node.extend(Node)
        node.instance_variable_set('@prev_node', self)
      end
    end
  end
end
