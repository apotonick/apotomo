### DISCUSS: is this the right technique here?
class JavaScriptSource
  def initialize(source)
    @source = source
  end
  
  def to_s; @source.to_s end
end
