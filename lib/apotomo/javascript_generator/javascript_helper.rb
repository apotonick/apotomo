module Apotomo
  module JavascriptHelper
    include ::ActionView::Helpers::JavaScriptHelper

    def javascript_selector_by_id(id)
      "##{id}"
    end

    def javascript_camelize(str)
      str.to_s.camelize.sub(/^\w/, str.to_s[0].downcase)
    end

    def javascript_underscore(str)
      str.to_s.underscore
    end

    def javascript_represent_as_string(arg)
      %Q{"#{escape_javascript(arg)}"}
    end

    def javascript_represent_as_number(arg)
      %Q{#{arg}}
    end

    def javascript_represent_as_literal(arg)
      %Q{#{javascript_camelize(arg)}}
    end

    def javascript_represent_as_array(arg)
      raise NotImplementedError
    end

    def javascript_represent_as_hash(arg)
      raise NotImplementedError
    end

    def javascript_represent_as_function(arg)
      raise NotImplementedError
    end

    def javascript_represent(arg)
      case arg
      when String;  javascript_represent_as_string(arg)
      when Numeric; javascript_represent_as_number(arg)
      when Symbol;  javascript_represent_as_literal(arg)
      when Array;   javascript_represent_as_array(arg)
      when Hash;    javascript_represent_as_hash(arg)
      else raise NotImplementedError
      end
    end

    def javascript_represent_as_arguments_list(*args)
      %Q{#{args.join(", ")}}
    end

    def javascript_action(action)
      %Q{.#{action};}
    end

    def javascript_call(method_name, *args)
      javascript_method_name = javascript_camelize(method_name) # DISCUSS: javascript_underscore ?
      javascript_args = args.collect { |arg| javascript_represent(arg) }

      javascript_action(%Q{#{javascript_method_name}(#{javascript_represent_as_arguments_list(*javascript_args)})})
    end

    def extract_args(required_count, *args)
      Array.new(required_count-args.count) + Array.wrap(args)
    end
  end
end
