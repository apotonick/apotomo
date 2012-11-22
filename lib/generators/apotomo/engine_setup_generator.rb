module Apotomo
  module Generators
    class EngineSetupGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def create_initializer
        template "apotomo.erb", "config/initializers/apotomo.rb"  
      end
    end
  end
end
