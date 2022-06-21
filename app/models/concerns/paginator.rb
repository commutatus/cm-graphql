module Paginator
    extend ActiveSupport::Concern
    module ClassMethods
      def list(per_page = DEFAULT_PER_PAGE, page = nil)
        paginated_list = {}
        per_page = DEFAULT_PER_PAGE if per_page == 0
        paginated_list[:list] = self.page(page || 1).per(per_page)
        FilteredList.new(paginated_list)
      end
    end
end