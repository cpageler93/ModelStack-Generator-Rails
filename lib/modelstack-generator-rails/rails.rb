require 'modelstack'

module ModelStack
  module Generator
    class Rails
      include ModelStack::Generator::Base

      def handle_options(options)
        puts "handle options #{options}"
      end

      def generate(data_model)
        puts "output to path #{self.absolute_output_path}"
        puts "generate data model"
      end

    end
  end
end