module Cucumber
  module Ast
    # Represents an inline argument in a step. Example:
    #
    #   Given the message
    #     """
    #     I like
    #     Cucumber sandwich
    #     """
    #
    # The text between the pair of <tt>"""</tt> is stored inside a PyString,
    # which is yielded to the StepDefinition block as the last argument.
    #
    # The StepDefinition can then access the String via the #to_s method. In the
    # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
    #
    # Note how the indentation from the source is stripped away.
    #
    class PyString #:nodoc:
      def self.default_arg_name
        "string"
      end

      def initialize(string)
        @string = string.gsub(/\\"/, '"')
      end

      def accept(visitor)
        return if $cucumber_interrupted
        visitor.visit_py_string(to_s)
      end
      
      def arguments_replaced(arguments) #:nodoc:
        string = @string
        arguments.each do |name, value|
          value ||= ''
          string = string.gsub(name, value)
        end
        PyString.new(string)
      end

      def has_text?(text)
        @string.index(text)
      end
    end
  end
end
