class <%= class_name %> < Apotomo::StatefulWidget
<% for action in actions -%>
  def <%= action %>
    render
  end
  
<% end -%>
end
