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
        i = 0

        i += 1 # step 1
        i += 1 # step 2
        i += 1 # step 3

        # step 4
        data_model[:scopes].each do |scope|
          i += number_of_steps_for_scope(scope)
        end

        return i
      end

      def number_of_steps_for_scope(scope)
        i = 1
        scope.controllers.each do |controller|
          i += number_of_steps_for_controller(controller)
        end
        return i
      end

      def number_of_steps_for_controller(controller)
        i = 1

        controller.actions.each do |action|
          i += 1
        end

        controller.child_controllers.each do |child_controller|
          i += number_of_steps_for_controller(child_controller)
        end

        return i
      end

      def generate

        # get data model
        app_name = data_model[:name]
        models   = data_model[:models]
        scopes   = data_model[:scopes]

        # create some variables
        self.rails_app_name = get_rails_app_name(app_name)
        self.rails_module_name = get_rails_module_name(app_name)
        self.rails_dir = File.join(self.absolute_output_path, rails_app_name)

        ##########################
        #    START GENERATION    #
        ##########################

        # Step 1: create output folder
        Proc.new {
          inc_step
          update_title "create output folder"
          log_message "create output folder"

          create_output_folder
        }.call

        # Step 2: Copy template to destination
        template_dir = File.join(self.absolute_gem_path, "template")
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

        # Step 4: enumerate scopes (prepare, no call)
        step_4_1 = nil
        step_4_2 = nil
        step_4 = Proc.new {
          update_title "enumerate scopes"
          scopes.each do |scope|
            inc_step

            if scope.controllers.length > 0
              log_message "#{scope.path} - controllers: #{scope.controllers.length}"
              scope.controllers.each do |controller|
                step_4_1.call(nil, controller)
              end
            else
              log_message "#{scope.path} - nothing to do"
            end

          end
        }

        # Step 4.1: enumerate controllers (prepare)
        step_4_1 = Proc.new { |parent_controllers, controller|
          inc_step
          p = parent_controllers ? parent_controllers.collect{|c|c.identifier} : "<null>"
          log_message "handle controller #{controller.identifier} in parent #{p}"

          controller.actions.each do |action|
            step_4_2.call(action)
          end

          controller.child_controllers.each do |child_controller|
            parent_controllers ||= []
            parent_controllers << controller
            step_4_1.call(parent_controllers, child_controller)
          end
        }

        # Step 4.2: enumerate actions (prepare)
        step_4_2 = Proc.new { |action|
          inc_step
          log_message "handle action #{action.identifier}"
        }

        # Step 4: call
        step_4.call

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