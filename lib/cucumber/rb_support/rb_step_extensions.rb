module Cucumber
  module StepExtensions
    def self.handle_arguments(extensions, args)
      return args unless @extension_module
      [@extension_module.reverse(args[0])]
    end

    def self.register_extension_module(extension_name, mod)
      @extension_module = mod
    end
  end
end

def StepExtensions(name, mod)
  
end