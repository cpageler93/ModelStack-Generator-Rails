require 'modelstack'

module ModelStack
  module Generator
    class Rails
      include ModelStack::Generator::Base


      attr_accessor :rails_dir


      ############################
      ##      BASE METHODS      ##
      ############################

      def handle_options(options)
        # puts "handle options #{options}"
      end

      def generate(data_model)

        # get rails name
        rails_app_name = get_rails_app_name(data_model[:name])

        # get scopes
        scopes = data_model[:scopes]

        # set rails dir
        self.rails_dir = File.join(self.absolute_output_path, rails_app_name)

        ##########################
        # START GENERATION

      end

      ############################
      ##     CUSTOM METHODS     ##
      ############################

      def get_rails_app_name(raw_name)
        rails_app_name = raw_name
        rails_app_name.downcase!
        rails_app_name.gsub!(' ', '_')

        return rails_app_name
      end

    end
  end
end