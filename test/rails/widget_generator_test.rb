require 'test_helper'
require 'rails_generator'
require 'rails_generator/scripts/generate'

Rails::Generator::Base.append_sources Rails::Generator::PathSource.new(:apotomo, File.join(File.dirname(__FILE__)+'/../../generators'))

class WidgetGeneratorTest < Test::Unit::TestCase
  context "Running script/generate widget" do
    setup do
      FileUtils.mkdir_p(fake_rails_root)
      @original_files = file_list
    end
    
    teardown do
      FileUtils.rm_r(fake_rails_root) 
    end
    
    context "MouseWidget squeak snuggle" do
      should "create the standard assets" do
        Rails::Generator::Scripts::Generate.new.run(%w(widget MouseWidget squeak snuggle), :destination => fake_rails_root)
        files = (file_list - @original_files)
        assert files.include?(fake_rails_root+"/app/cells/mouse_widget.rb")
        assert files.include?(fake_rails_root+"/app/cells/mouse_widget/squeak.html.erb")
        assert files.include?(fake_rails_root+"/app/cells/mouse_widget/snuggle.html.erb")
        assert files.include?(fake_rails_root+"/test/widgets/mouse_widget_test.rb")
      end
      
      should "create haml assets with --haml" do
        Rails::Generator::Scripts::Generate.new.run(%w(widget MouseWidget squeak snuggle --haml), :destination => fake_rails_root)
        files = (file_list - @original_files)
        assert files.include?(fake_rails_root+"/app/cells/mouse_widget.rb")
        assert files.include?(fake_rails_root+"/app/cells/mouse_widget/squeak.html.haml")
        assert files.include?(fake_rails_root+"/app/cells/mouse_widget/snuggle.html.haml")
        assert files.include?(fake_rails_root+"/test/widgets/mouse_widget_test.rb")
      end
    end
  end
  
  private
  def fake_rails_root
    File.join(File.dirname(__FILE__), 'rails_root')  
  end
  
  def file_list
    Dir.glob(File.join(fake_rails_root, "**/*"))
  end 
end
