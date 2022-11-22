require 'rails'
module CmGraphql
  class Engine < Rails::Engine
    isolate_namespace CmGraphql
  end
end