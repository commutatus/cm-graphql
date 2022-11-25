# CmGraphql

This should help you to install graphql and setup the basics on any new rails application.
- Adds Graphql gem and runs the graphql installer
- Copies the grapqhl schema template which has the rescue block configured.
- Certain files like grapqhl query, input and exceptions are inside the gem, which makes the listing of records easier.

## Install

Add the gem to the Gemfile

```
gem 'cm-graphql'
```

## Setup

If this is the first time graphql is getting added to the project, run the following generator

```
rails g cm_graphql:add_graphql
```

This will run the graphql generator `graphql:install` and copy the graphql schema template.

## Generator

Another generator to help you get started with a basic list endpoint is 

```
rails g cm_graphql:list_api model_name
rails g cm_graphql:list_api course


# Sample grapqhl request

query {
	courses(paging: {
		pageNo: 1
		perPage: 100
	}) {
		paging {
			currentPage
			totalPages
			totalCount
		}	
		data {
			id
      name
		}
	}
}
```

This will add the necessary files to the application.
- course_list_type
- course_type
- course_query

Mount the engine at 
```
mount CmGraphql::Engine => "/cm-graphql"
```

And you are done, you can test out the pagination.

## Explaination on how this works.

1. Kaminari Gem has `page` and `per` methods. These methods are used to set the page no and records per page of a model.
2. The paging Input type in `app/graphql/types/inputs/base/paging.rb` exposes a interface to the frontend where the frontend can enter page no and records per page.
3. The query uses a `list` method on the model. This method is inherited by the model from the paginator concern.
4. We apply the kaminari method in the list method to apply pagination to the model.
5. The paginator then calls the filtered_list model to arrange the model data and paging data in a representable way. This helps us make sure all the pagination follow the same pattern for data representation.
6. The paging_type in `app/graphql/types/objects/base/paging_type.rb` is used to represent the paging data to the frontend.
7. The pagination and model data is represented with object type in `app/graphql/types/objects/example_list_type.rb`.
8. And we have successfully applied pagination to our graphql project.
