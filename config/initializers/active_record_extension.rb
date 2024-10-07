require_relative '../../app/models/concerns/paginator'

ActiveSupport.on_load(:active_record) do
  module ActiveRecord
    class Base
      include Paginator
    end
  end
end
