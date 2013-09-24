require 'test_helper'

class TreeNodeTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "initialization" do
    before do
      @mum = mouse('mum')
        @mum << mouse_mock(:kid)
        @kid = @mum[:kid]
          @kid << mouse_mock(:grandchild)
          @grandchild = @kid[:grandchild]
        @mum << mouse_mock(:another_kid)
        @another_kid = @mum[:another_kid]
      @another_mum = mouse('another_mum')
    end

    it "respond to #setup_tree_node" do
      @another_mum.setup_tree_node(@mum)

      assert @another_mum, @mum[:another_mum]
      assert @mum, @another_mum.parent
    end

    describe "#to_s" do
      it "return its description" do
        assert_match /^Node ID\: \w+ Parent\: \w+ Children\: \d+ Total Nodes\: \d+$/, @mum.to_s
      end

      it "return correct Node ID" do
        @kid.stub :widget_id, 'awesome_widget' do
          assert_match /Node ID\: awesome_widget/, @kid.to_s
        end
      end

      it "return correct Node ID if it's non-String" do
        @kid.stub :widget_id, :awesome_widget do
          assert_match /Node ID\: awesome_widget/, @kid.to_s
        end
      end

      it "return correct Parent ID" do
        @mum.stub :name, 'awesome_mum' do
          assert_match /Parent\: awesome_mum/, @kid.to_s
        end
      end

      it "return correct Parent ID if it's non-String" do
        @mum.stub :name, :awesome_mum do
          assert_match /Parent\: awesome_mum/, @kid.to_s
        end
      end

      it "return correct Total Nodes" do
        @kid.stub :size, 123 do
          assert_match /Total Nodes\: 123/, @kid.to_s
        end
      end

      # TODO: test Children after #children_size will be extracted
    end

    describe "#add_widget" do
      it "add widget if it is not already added and return it" do
        mouse_sister = mouse(:mouse_sister)
        @mum.add_widget(mouse_sister)

        assert_equal mouse_sister, @mum[:mouse_sister]
      end

      it "raise an exception if widget is already added" do
        assert_raises RuntimeError do
          @mum.add_widget(@kid)
        end
      end

      it "raise an exception if widget with the same name is already added" do
        assert_raises RuntimeError do
          new_kid = mouse(:kid)
          @mum.add_widget(new_kid)
        end
      end
    end

    describe "#remove!" do
      describe "when try to remove a child" do
        it "remove child" do
          @mum.remove!(@kid)

          assert_nil @mum[:kid]
        end

        it "make child #root?'ed" do
          @mum.remove!(@kid)

          assert @kid.root?
        end

        it "return child" do
          assert_equal @kid, @mum.remove!(@kid)
        end
      end

      describe "when try to remove a foreign widget" do
        it "make widget #root?'ed" do
          @kid.remove!(@another_mum)
          assert @another_mum.root?
        end

        it "return widget" do
          assert_equal @another_kid, @kid.remove!(@another_kid)
        end
      end
    end

    describe "#parent=" do
      it "set instance as parent" do
        @kid.send(:parent=, @another_mum)

        assert_equal "another_mum", @kid.parent.name
      end
    end

    describe "#root!" do
      it "set instance as root" do
        @kid.send(:root!)

        assert_equal :kid, @grandchild.root.name
      end
    end

    describe "#root?" do
      it "return true if parent doesn't exist" do
        assert @mum.root?
      end

      it "return false if parent exists" do
        assert_not @kid.root?
      end
    end

    describe "#parent" do
      it "return parent if it exists" do
        assert_equal @mum, @kid.parent
      end

      it "return nil if it doesn't exist" do
        assert_equal nil, @mum.parent
      end
    end

    describe "#children" do
      it "return children unless a block given" do
        assert_equal [@kid, @another_kid], @mum.children
      end

      it "return children if a block given" do
        assert_equal [@kid, @another_kid], @mum.children { |child| child }
      end

      # TODO: check if block yielded
    end

    describe "#each" do
      it "return children" do
        assert_equal [@kid, @another_kid], @mum.each { |widget| widget }
      end

      # TODO: check if block yielded
    end

    describe "accessing children by #[]" do
      it "return child by its name" do
        assert_equal @kid, @mum[:kid]
      end

      it "return child by its number" do
        assert_equal @kid, @mum[0]
        assert_equal @another_kid, @mum[1]
      end
    end

    describe "#size" do
      it "return subnodes count + 1" do
        assert_equal 4, @mum.size
        assert_equal 2, @kid.size
        assert_equal 1, @grandchild.size
        assert_equal 1, @another_kid.size
        assert_equal 1, @another_mum.size
      end
    end

    describe "#root" do
      it "return root widget for a kid" do
        assert_equal @mum, @mum.root
        assert_equal @mum, @kid.root
        assert_equal @mum, @grandchild.root
      end
    end

    describe "#path" do
      it "return the path from the widget to root" do
        assert_equal "mum", @mum.path
        assert_equal "mum/kid", @kid.path
        assert_equal "mum/kid/grandchild", @grandchild.path
      end
    end

    # TODO: test #printTree

    # TODO: test #<=>

    # TODO: test #find_by_path

  end
end
