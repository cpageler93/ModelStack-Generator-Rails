require 'modelstack'
require 'fileutils'

module ModelStack
  module Generator
    class Rails
      include ModelStack::Generator::Base

      attr_accessor :rails_app_name
      attr_accessor :rails_module_name
      attr_accessor :rails_dir

      ############################
      ##      BASE METHODS      ##
      ############################

      def handle_options(options)
        # puts "handle options #{options}"
      end

      def number_of_steps
        return 3
      end

      def deep_hash(obj)
        if obj.is_a?(Array)
          new_array = []
          obj.each do |value|
            new_array << deep_hash(value)
          end
          return new_array
        elsif obj.is_a?(Hash)
          new_hash = {}
          obj.each do |key, value|
            new_hash[key] = deep_hash(value)
          end
          return new_hash
        else
          if obj.respond_to?(:as_json)
            return obj.as_json
          else
            return obj
          end
        end
      end

      def generate

        app_name = data_model[:name]
        scopes = data_model[:scopes]

        # create some variables
        self.rails_app_name = get_rails_app_name(app_name)
        self.rails_module_name = get_rails_module_name(app_name)
        self.rails_dir = File.join(self.absolute_output_path, rails_app_name)

        ##########################
        # START GENERATION


        # TODO: Extract to base class
        spec = Gem::Specification.find_by_name("modelstack-generator-rails")
        gem_root = spec.gem_dir

        log_message deep_hash(data_model).to_json
        return


        # Step 1: create output folder
        Proc.new {
          inc_step
          update_title "create output folder"
          log_message "create output folder"

          create_output_folder
        }.call

        # Step 2: Copy Template to destination
        template_dir = File.join(gem_root, "template")
        Proc.new {
          inc_step
          update_title "copy template"
          log_message "copy template to #{self.rails_dir}"

          FileUtils.copy_entry(template_dir, self.rails_dir)
        }.call

        # Step 3: fill out base files
        Proc.new {
          inc_step
          update_title "fill out base files"
          log_message "fill out base files"

          # fill out application.rb
          fill_out_file(path_for_file("config/application.rb"), {
            'RailsAppModuleName' => self.rails_module_name
          })

          # fill out session_store.rb
          session_key = "_#{self.rails_app_name}_session"
          fill_out_file(path_for_file("config/initializers/session_store.rb"), {
            'rails_app_session_store_key' => session_key
          })

        }.call

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

      def get_rails_module_name(raw_name)
        get_rails_app_name(raw_name).camelize
      end

      def path_for_file(file_name)
        File.join(self.rails_dir, file_name)
      end

      def fill_out_file(file_path, replacements)
        file_content = IO.read(file_path)

        replacements.each do |placeholder, value|
          file_content.gsub!("{{{#{placeholder}}}}", value)
        end

        IO.write(file_path, file_content)
      end

    end
  end
end