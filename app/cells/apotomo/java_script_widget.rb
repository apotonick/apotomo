module Apotomo
  
  ### TODO: if a state doesn't return anything, the view-finding is invoked, which
  ###   is nonsense in a JS widget. current work-around: return render :js => ""
  
  class JavaScriptWidget < StatefulWidget
    def frame_content(content)
      content
    end
  end
  
end
