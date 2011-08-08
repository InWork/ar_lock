require 'ar_lock'
require 'rails'

module ArLock
  class Engine < ::Rails::Engine
    engine_name :ar_lock
  end
end
