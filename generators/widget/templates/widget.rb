class <%= class_name %>Cell < Apotomo::StatefulWidget

<% for action in actions -%>
  def <%= action %>
    render
  end
<% end -%>
end
