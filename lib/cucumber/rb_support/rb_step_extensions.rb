module Cucumber
  class StepExtensions

    def initialize(extension_args = [])
      @extension_args = [extension_args].flatten
    end
    require 'g'

    def handle_arguments(args = [])
      return args if @extension_args.empty?
      run_extensions_on(args)
    end

    def run_extensions_on(args)
      [methods_for(args), args].transpose.map do |extension_method, arg|
        self.send(extension_method, arg)
      end
    end

    def methods_for(args)
      methods = @extension_args
      if(methods.size == 1)
        methods = (methods * args.size)
      end
      methods      
    end

    def self.register_extension_module(*extension_modules)
      extension_modules.each {|ext| self.send(:include,ext) }
    end
  end
end

def StepExtensions(name, mod)

end