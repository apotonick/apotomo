require 'rails_generator/generators/components/controller/controller_generator'

class WidgetGenerator < ControllerGenerator
  def add_options!(opt)
    opt.on('--haml') { |value| options[:view_format] = 'haml' }
  end
  
  def manifest
    options.reverse_merge! :view_format => 'erb'
    
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}"

      # Directories
      m.directory File.join('app/cells', class_path)
      m.directory File.join('app/cells', class_path, file_name)
      m.directory File.join('test/widgets')
      
      # Widget
      m.template 'widget.rb', File.join('app/cells', class_path, "#{file_name}.rb")
      
      # View template for each state.
      format = options[:view_format]
      actions.each do |state|
        path = File.join('app/cells', class_path, file_name, "#{state}.html.#{format}")
        m.template "view.html.#{format}", path, :assigns => { :action => state, :path => path }
      end
      
      # Functional test for the widget.
      m.template 'functional_test.rb', File.join('test/widgets/', "#{file_name}_test.rb"), :assigns => {:states => actions}
    end
  end
end
