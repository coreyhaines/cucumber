module Cucumber
  module RbSupport
    module Transforms
    end
    class ExplicitTransforms
      def initialize(transforms)
        @transforms = [transforms].flatten if transforms
      end

      def transform(these_args)
        return these_args unless @transforms

        transforms = transforms_for(these_args)
        [transforms, these_args].transpose.map do |transform_method, arg|
          transform_method ? Transforms.send(transform_method,arg) : arg
        end
      end

      def transforms_for(these_args)
        @transforms.size == 1 ? (@transforms * these_args.size) : @transforms
      end
    end
  end
end
def ExplicitTransforms(mod)
  Cucumber::RbSupport::Transforms.extend(mod)
end
