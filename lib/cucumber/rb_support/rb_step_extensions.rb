module Cucumber
  class StepExtensions
    @@extension_modules = {}

    def initialize(extension_args)
      @extension_args = extension_args
    end

    def handle_arguments(args)
      return args if @@extension_modules.empty? || @extension_args.values.empty?
      
      run_extensions_on(args)
    end

    def run_extensions_on(args)
      [methods_for(args), args].transpose.map do |extension_method, arg|
        @@extension_modules.values[0].send(extension_method, arg)
      end
    end

    def methods_for(args)
      methods = [@extension_args.values[0]].flatten
      if(methods.size == 1)
        methods = (methods * args.size)
      end
      methods      
    end

    def self.register_extension_module(extension_modules)
      @@extension_modules.merge!(extension_modules)
    end
  end
end

def StepExtensions(name, mod)

end