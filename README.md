# Apotomo

**Web Components for Rails.**

[![TravisCI Build Status](https://secure.travis-ci.org/apotonick/apotomo.png)](http://travis-ci.org/apotonick/apotomo)

## Overview

Do you need an _interactive user interface_ for your Rails application? A cool Rich Client Application with dashboards, portlets and AJAX, Drag&Drop and jQuery?

Is your controller gettin' fat? And your partial-helper-AJAX pile is getting out of control?

Do you want a framework to make the implementation easier? _You want Apotomo._ 

**Apotomo** is based on [Cells](http://github.com/apotonick/cells), the popular View Components framework for Rails.

It gives you widgets and encapsulation, bubbling events, AJAX page updates, rock-solid testing and more. Check out <http://apotomo.de> for more information.

## Installation

Easy as hell. You just need Ruby 1.9.3/2.0.0 and Rails 3/4.

Add Apotomo to your `Gemfile`:

```ruby
gem `apotomo`
```

## Example

A _shitty_ example is worse than a _shitty_ framework, so let's choose wisely...

Say you had a blog application. The page showing the post should have a comments block, with a list of comments and a form to post a new comment. Submitting should validate and send back the updated comments list, via AJAX.

Let's wrap that comments block in a widget.

## Generate

Go and generate a widget stub.

```shell
rails generate apotomo:widget Comments display write -e haml
```

```
create  app/widgets/
create  app/widgets/comments_widget.rb
create  app/widgets/comments/
create  app/widgets/comments/display.html.haml
create  app/widgets/comments/write.html.haml
create  test/widgets/
create  test/widgets/comments_widget_test.rb
```

Nothing special.

## Plug it in

You now tell your controller about the new widget.

```ruby
class PostsController < ApplicationController
  
  has_widgets do |root|
    root << widget(:comments, :post => @post)
  end
```

This creates a widget instance called `comments_widget` from the class CommentsWidget.  We pass the current post into the widget - the block is executed in controller instance context, that's were `@post` comes from. Handy, isn't it?

## Render the widget

Rendering usually happens in your controller view, `app/views/posts/show.html.haml`, for instance.

```haml
%h1= @post.title
%p
  = @post.body
%p
  = render_widget :comments
```

## Write the widget

A widget is like a cell which is like a mini-controller.

```ruby
class CommentsWidget < Apotomo::Widget
  responds_to_event :post
  
  def display(args)
    @comments = args[:post].comments # the parameter from outside.

    render
  end
```

Having `display` as the default state when rendering, this method collects comments to show and renders its view.

And look at line 2 - if encountering a `:post` event we invoke `#post`, which is simply another state. How cool is that? 

```ruby
  def post(event)
    @comment = Comment.new :post_id => event[:post_id]
    @comment.update_attributes event[:comment] # a bit like params[].
    
    update :state => :display
  end
end
```

The event is processed with three steps in our widget:

* create the new comment
* re-render the `display` state
* update itself on the page

Apotomo helps you focusing on your app and takes away the pain of _action dispatching_ and _page updating_.

## Triggering events

So how and where is the `:post` event triggered?

Take a look at the widget's view `display.html.haml`.

```haml
= widget_div do
  %ul
    - for comment in @comments
      %li= comment.text
  
  = form_for :comment, :url => url_for_event(:post), :remote => true do |f|
    = f.text_field :text
    = f.submit
```

That's a lot of familiar view code, almost looks like a _partial_.

As soon as the form is submitted, the form gets serialized and sent using the standard Rails mechanisms. The interesting part here is the endpoint URL returned by #url_for_event as it will trigger an Apotomo event.

## Event processing

Now what happens when the event request is sent? Apotomo - again - does three things for you, it

* _accepts the request_ on a special event route it adds to your app
* _triggers the event_ in your ruby widget tree, which will invoke the `#post` state in our comment widget
* _sends back_ the page updates your widgets rendered

## JavaScript Agnosticism

In this example, we use jQuery for triggering. We could  also use Prototype, RightJS, YUI, or a self-baked framework, that's up to you.

Also, updating the page is in your hands. Where Apotomo provides handy helpers as `#replace`, you could also _emit your own JavaScript_.

Look, `replace` basically generates

```ruby
jQuery("comments").replaceWith(<the rendered view>);
```

If that's not what you want, do

```ruby
def post(event)
  if event[:comment][:text].explicit?
    render :text => 'alert("Hey, you wanted to submit a pervert comment!");'
  end
end
```

Apotomo doesn't depend on _any_ JS framework - you choose!

## Testing

Apotomo comes with its own test case and assertions to _build rock-solid web components_.

```ruby
class CommentsWidgetTest < Apotomo::TestCase
  has_widgets do |root|
    root << widget(:comments, :post => @pervert_post)
  end
  
  def test_render
    render_widget :comments
    assert_select "li#me"
    
    trigger :post, :comment => {:text => "Sex on the beach"}
    assert_response 'alert("Hey, you wanted to submit a pervert comment!");'
  end
end
```

You can render your widgets, spec the markup, trigger events and assert the event responses, so far. If you need more, let us know!

## Bubbling events

Note: Let's write this paragraph!

## Bugs, Community

Please visit <http://apotomo.de>, the official project page with _lots_ of examples.

If you have questions, visit us in the IRC channel #cells at irc.freenode.org.

If you wanna be cool, subscribe to our [feed](http://feeds.feedburner.com/Apotomo)!

## License

Copyright (c) 2007-2013 Nick Sutterer <apotonick@gmail.com>

Released under the MIT License.
