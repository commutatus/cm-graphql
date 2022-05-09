# Template-paging-api

## How to use this template

1. Add [Kaminari](https://rubygems.org/gems/kaminari) gem in the gem file and run `bundle`
2. Drap and drop the files from repo to your project.
3. Include the paginator concern in your model. For example :-

```
class Example < ApplicationRecord
  include Paginator
end
```

4. Create a list type object in `app/graphql/types/objects/example_list_type.rb`. For Example :-

```
module Types::Objects
  class ExampleListType < Types::BaseObject
    graphql_name "ExampleListType"

    field :paging, Types::Objects::Base::PagingType, null: true
    field :data, [Types::Objects::ExampleType], null: false
  end
end
```

5. Call the `list` method in your query, it is inherited from paginator concern.

```
module Queries::Example
    include Types::BaseInterface

    graphql_name "ExampleQueries"
    field :examples, Types::Objects::ExampleListType, description: "Returns a list of examples", null: true do
        argument :filters, Inputs::ExampleFilterInput, required: false
        argument :paging, Inputs::Base::Paging, required: false
    end

    def examples(filters:, paging:)
        Example.example_type_filter(filters&.example_type).distinct.list(paging&.per_page, paging&.page_no)
    end
end
```

6. And you are done, you can test out the pagination.

## Explaination on how this works.

1. Kaminari Gem has `page` and `per` methods. These methods are used to set the page no and records per page of a model.
2. The paging Input type in `app/graphql/types/inputs/base/paging.rb` exposes a interface to the frontend where the frontend can enter page no and records per page.
3. The query uses a `list` method on the model. This method is inherited by the model from the paginator concern.
4. We apply the kaminari method in the list method to apply pagination to the model.
5. The paginator then calls the filtered_list model to arrange the model data and paging data in a representable way. This helps us make sure all the pagination follow the same pattern for data representation.
6. The paging_type in `app/graphql/types/objects/base/paging_type.rb` is used to represent the paging data to the frontend.
7. The pagination and model data is represented with object type in `app/graphql/types/objects/example_list_type.rb`.
8. And we have successfully applied pagination to our graphql project.
