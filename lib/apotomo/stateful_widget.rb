require 'apotomo/widget'
require 'apotomo/persistence'

module Apotomo
  class StatefulWidget < Widget
    include Persistence
  end
end