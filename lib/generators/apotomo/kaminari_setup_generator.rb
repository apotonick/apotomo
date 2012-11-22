module Apotomo
  module Generators
    class KaminariSetupGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_initializer
        append_to_file kaminari_config_file do
          kaminari_config_code
        end
      end

      protected

      def kaminari_config_file
        "config/initializers/kaminari_config.rb"
      end

      def kaminari_config_code
        %q{
Kaminari::Helpers::Tag.class_eval do
  def to_s(locals = {}) #:nodoc:
    @template.render :partial => "../views/kaminari/#{@theme}#{self.class.name.demodulize.underscore}", :locals => @options.merge(locals)
  end
end}
      end
    end
  end
end