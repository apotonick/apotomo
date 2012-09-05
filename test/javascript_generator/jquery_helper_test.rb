require 'test_helper'

class JQueryHelperTest < Test::Unit::TestCase
  context "The JQueryHelper" do
    setup do
      @helper = Apotomo::JavascriptGenerator::JqueryHelper
    end

    context '#find_element' do
      context 'args: id, selector' do
        should "generate full action" do
          assert_equal "$(\"#my_widget\").find(\".item\")", @helper.find_element('my_widget', '.item')
        end
      end

      context 'args: selector' do
        should "generate selector only" do
          assert_equal "$(\".item\")", @helper.find_element(nil, '.item')
        end
      end
    end
        
    context '#jq_action' do
      context 'args: id, selector, action' do
        should "generate full action" do
          assert_equal "$(\"#my_widget\").find(\".item\").empty();", @helper.jq_action('my_widget', '.item', 'empty()')
        end
      end

      context 'args: selector, action' do
        should "generate selector only" do
          assert_equal "$(\".item\").empty();", @helper.jq_action('.item', 'empty()')
        end
      end
    end

    context '#inv_markup_action' do
      context 'args: selector, markup, action' do
        should "generate full action" do
          assert_equal "$(\"<b>hello > world<\\/b>\").replaceAll(\"#my_widget\");", @helper.inv_markup_action('#my_widget', '<b>hello > world</b>', :replace_all)
        end
      end
    end  

    context '#markup_action' do
      context 'args: id, selector, markup, action' do
        should "generate full action" do
          assert_equal "$(\"#my_widget\").find(\".item\").append(\"<b>hello > world<\\/b>\");", @helper.markup_action('my_widget', '.item', '<b>hello > world</b>', :append)
        end
      end

      context 'args: selector, markup, action' do
        should "generate selector action" do
          assert_equal "$(\".item\").append(\"<b>hello > world<\\/b>\");", @helper.markup_action('.item', '<b>hello > world</b>', :append)
        end
      end
    end      
  end
end