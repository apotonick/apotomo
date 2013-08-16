module Apotomo
  module JavascriptHelper
    include ::ActionView::Helpers::JavaScriptHelper

    def selector_by_id(id)
      "##{id}"
    end

    def camelize(str)
      str.to_s.camelize.sub(/^\w/, str.to_s[0].downcase)
    end

    def underscore(str)
      str.to_s.underscore
    end

    def represent_as_string(arg)
      %Q{"#{escape_javascript(arg)}"}
    end

    def represent_as_number(arg)
      %Q{#{arg}}
    end

    def represent_as_literal(arg)
      %Q{#{camelize(arg)}}
    end

    def represent_as_array(arg)
      raise NotImplementedError
    end

    def represent_as_hash(arg)
      raise NotImplementedError
    end

    def represent_as_function(arg)
      raise NotImplementedError
    end

    def represent(arg)
      case arg
      when String;  represent_as_string(arg)
      when Numeric; represent_as_number(arg)
      when Symbol;  represent_as_literal(arg)
      when Array;   represent_as_array(arg)
      when Hash;    represent_as_hash(arg)
      else raise NotImplementedError
      end
    end

    def represent_as_arguments_list(*args)
      %Q{#{args.join(", ")}}
    end

    def action(action)
      %Q{.#{action};}
    end

    def call(method_name, *args)
      method_name = camelize(method_name) # DISCUSS: underscore ?
      args = args.collect { |arg| represent(arg) }

      action(%Q{#{method_name}(#{represent_as_arguments_list(*args)})})
    end

    def extract_args(required_count, *args)
      Array.new(required_count-args.count) + Array.wrap(args)
    end
  end
end
