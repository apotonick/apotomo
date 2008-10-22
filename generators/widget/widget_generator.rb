require 'rails_generator/generators/components/controller/controller_generator'

class WidgetGenerator < ControllerGenerator
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Cell"

      # Directories
      m.directory File.join('app/cells', class_path)
      m.directory File.join('app/cells', class_path, file_name)
      
      # Cell
      m.template 'widget.rb', File.join('app/cells', class_path, "#{file_name}_cell.rb")
      
      # View template for each state.
      actions.each do |action|
        path = File.join('app/cells', class_path, file_name, "#{action}.html.erb")
        m.template 'view.html.erb', path,
          :assigns => { :action => action, :path => path }
      end
      
      # Functional test for the widget.
      m.template 'functional_test.rb', File.join('test/functional/', "test_#{file_name}_cell.rb")
    end
  end
end
