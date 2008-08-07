= Apotomo

Apotomo is a stateful widget component framework for Rails.

Its event-driven concept introduces a GUI-like development style for Rich Web
Applications. The event handling with callbacks moves away from the one-big-view 
thinking to a modular component-oriented approach.

Persistent widgets can be embedded into existing controllers and implement only parts of a page, or they can model a complete application, leaving it open to the Rails developer how much Apotomo he wants.


== What are widgets?

Apotomo::StatefulWidget is the base class for any widget in Apotomo. Widgets are derived cells[http://cells.rubyforge.org/rdoc], meaning
they basically look and behave like super-fast mini-controllers known from Rails.
State actions in a widget are like controller actions - they implement
the business logic in a method and can render a corresponding view.

I will demonstrate Apotomo's key concepts using the famous and tiresome counter 
example:

 class MyCounterCell < Apotomo::StatefulWidget
   def transition_map
     { :counter => [:_increment]
     }
  end

  def counter
    @count = 0
    nil
  end

  def _increment
    @count += 1
    state_view :counter
  end
end

This widget could be embedded into an existing Rails controller using the 
Apotomo::ControllerHelper#act_as_widget method.

 class ExistingController < ApplicationController
   include Apotomo::ControllerHelper

   def counter_action
     act_as_widget('nicks_counter')
   end
 end

A call to Apotomo::ControllerHelper#act_as_widget instructs Apotomo to look in the
ApplicationWidgetTree for
a widget named <tt>nicks_counter</tt>, render this widget and receive and process 
apotomo events from now on.
The ApplicationWidgetTree (currently it's "only" static) is located in the file 
<tt>app/apotomo/application_widget_tree.rb</tt> and could look like this:

 class ApplicationWidgetTree < Apotomo::WidgetTree
   def draw(root)
     root << cell(:my_counter, :counter, 'nicks_counter')
   end
 end

This models the application. Our current demonstration app is quite small, but anyway
we attach the MyCounterCell widget to the root and name it <tt>nicks_counter</tt>.
As its start state is set to <tt>:counter</tt>, the widget will start in 
this state when it is invoked by Apotomo::ControllerHelper#act_as_widget.

The <tt>counter</tt> state method just resets the instance variable <tt>@count</tt>
and automatically renders the corresponding view in
<tt>app/cells/my_counter/counter.html.erb</tt>:

 I am a counter: <h1><%= @count %></h1>
 <%= link_to_event "Increment me!", :state => :_increment %>


So when browsing to <tt>http://localhost:3000/existing/counter_action</tt> the user will see a zero counter
and a link. Being a curious user, he clicks on this link!


== Transitions

Such a curiousity is rewarded by triggering an Apotomo event. Some default event
handler sends the widget <tt>nicks_counter</tt> to its <tt>:_increment</tt> state. 
Looking at Apotomo::StatefulWidget#transition_map in our widget, this is an allowed transition.

The <tt>_increment</tt> state method makes a small addition and - surprise! -
increments the counter. By calling Apotomo::StatefulWidget#state_view it instructs 
the rendering mechanism to render the view we already know. 


== Persistence

Where does the instance variable <tt>@count</tt> come from in the state method
<tt>_increment</tt>? Remember, it's a <em>stateful</em> widget! They save their state between 
requests and restore all instance variables in the next state as if there wouldn't have
been any request at all.


== Nesting

Just for the sake of fun we write another widget with one state only. It will 
simply display a small form. Right now, this doesn't make any sense. And it won't make 
sense later.

  class FormCell < Apotomo::StatefulWidget
    def dumb_form
    end
  end

When rendered the widget would just be a form with an input field and a submit button.
Let's push it into our application in the ApplicationWidgetTree:

  class ApplicationWidgetTree < Apotomo::WidgetTree
    def draw(root)
      root << form= cell(:form, :dumb_form, 'my_dumb_form')
        form << cell(:my_counter, :counter, 'nicks_counter')  # we already know that.
    end
  end

What's going on here? We <em>nested</em> the widgets! When rendered, we will see the
simple form <em>containing</em> a counter widget .

== Events

Let's assume the corresponding view for <tt>:dumb_form</tt> would be
<tt>app/cells/form/dumb_form.html.erb</tt>:
  
  <%= form_to_event :type => :dumb %>
    <%= text_field_tag :some_text %>
    <%= submit_tag %>
  </form>

  <%= @content.join("") %>
  
When submitted Apotomo::ViewHelper#form_to_event triggers an event, it's type will be
<tt>:dumb</tt> and the event source is <tt>my_dumb_form</tt>. This is amazing, anyway,
nothing will happen since there isn't an event <em>handler</em> for this event.

== Event Handler

It would be cool if the counter widget could observe this form. If the user entered an
integer in the input field, it could be the new counter value. Instantly we extend 
<tt>MyCounterCell</tt>:

  class MyCounterCell < Apotomo::StatefulWidget
    def transition_map
      { :counter    => [:_increment],
        :_increment => [:_increment, :_set],
        :_set       => [:_increment, :_set],
      }
    end
    
    def _set
      @count = param(:some_text) # I omit a type check! Shame on me!
      state_view :counter
    end
    
    ...
    ...
  end

We <em>know</em> that the form fires a <tt>:dumb</tt> event when submitted, so we should
watch out for this event. In the ApplicationWidgetTree, we add:

    root.watch(:dumb, 'nicks_counter', :_set, nil)

This attaches an event handler to the root widget with Apotomo::EventAware#watch. 
It says "whenever a <tt>:dumb</tt> event is triggered, regardless of the event source,
invoke the state <tt>:_set</tt> on the widget named <tt>nicks_counter</tt>.

Ok, summarize this: 
* the user enters some value in the input field
* he submits the form thus firing an event
* the event bubbles up from the source up to root, where it is catched
* the counter widget is updated, having the value the user entered
Cool!


== Parameter accessing

Widgets shouldn't access parameters from outside with <tt>#params</tt> anymore. They have a more
sophisticated concept with Apotomo::StatefulWidget#param.

Remember the <tt>_set</tt> method in our counter? It retrieves its new counter value by
asking for it:
  @count = param(:some_text) 

This request <em>bubbles up</em> the wigdet hierarchy, asking every widget on its way if
it knows the value for <tt>:some_text</tt>. The questioning finally ends up in looking into 
<tt>params[]</tt> in the root widget.
We could override this behaviour by overwriting Apotomo::StatefulWidget#param_for in an ascending widget.

== Bookmarkable links

Links in widget views can be made bookmarkable by adding <tt>:static => true</tt> 
to the options in Apotomo::ViewHelper#link_to_widget. The link contains enough state
information to restore the exact state the widget was in when it was invoked the last
time.

== File uploads with AJAX

A programmer will never encounter the file upload problem with AJAX in an Apotomo widget.
Apotomo automatically manages the upload and page update process as soon as there is 
<tt>:multipart => :true</tt> in Apotomo::ViewHelper#form_to_event.


== Bugs, Community
Please visit http://apotomo.de, the official project page with <em>lots</em> of examples.
Join the mailing list and visit us in the IRC channel. More information is
here[http://apotomo.de/download].


== License
Copyright (c) 2007, 2008 Nick Sutterer <apotonick@gmail.com>

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


