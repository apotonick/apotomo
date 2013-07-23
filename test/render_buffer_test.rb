require 'test_helper'

class RenderTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "#render_buffer" do
    before do
      @mum = mouse('mum')
    end

    describe "via 'buf << method_call'" do
      before do
        @mum.instance_eval do
          def eating
            render_buffer do |buf|
              buf << render(:text => "burp!!!")
            end
          end
        end
      end

      it "render the call result" do
        assert_equal "burp!!!", @mum.invoke(:eating)
      end
    end

    describe "via 'buf.method_call'" do
      before do
        @mum.instance_eval do
          def eating
            render_buffer do |buf|
              buf.render(:text => "burp!!!")
            end
          end
        end
      end

      it "render the call result" do
        assert_equal "burp!!!", @mum.invoke(:eating)
      end
    end

    describe "via 'buf.method_call' and 'buf << method_call'" do
      before do
        @mum.instance_eval do
          def eating
            render_buffer do |buf|
              buf.render(:text => "burp!!!")
              buf << render(:text => "curp!!!")
            end
          end
        end
      end

      it "render the concatenation of call results" do
        assert_equal "burp!!!curp!!!", @mum.invoke(:eating)
      end
    end

    describe "via 'buf.method_call' and 'buf << method_call' and just 'method_call'" do
      before do
        @mum.instance_eval do
          def eating
            render_buffer do |buf|
              buf.render(:text => "burp!!!")
              buf << render(:text => "curp!!!")
              render(:text => "durp!!!")
            end
          end
        end
      end

      it "render the concatenation of call results (via 'buf.method_call' and 'buf << method_call' only)" do
        assert_equal "burp!!!curp!!!", @mum.invoke(:eating)
      end
    end

    describe "with custom method" do
      before do
        @mum.instance_eval do
          def drinking(thing)
            "furp!!!#{thing}"
          end
        end
      end

      describe "via 'buf << method_call'" do
        before do
          @mum.instance_eval do
            def eating
              render_buffer do |buf|
                buf.drinking("water")
              end
            end
          end
        end

        it "render the call result" do
          assert_equal "furp!!!water", @mum.invoke(:eating)
        end
      end

      describe "via 'buf.method_call'" do
        before do
          @mum.instance_eval do
            def eating
              render_buffer do |buf|
                buf << drinking("water")
              end
            end
          end
        end

        it "render the call result" do
          assert_equal "furp!!!water", @mum.invoke(:eating)
        end
      end
    end
  end
end
