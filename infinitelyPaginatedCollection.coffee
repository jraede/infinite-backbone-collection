###
 * This allows you to have an "infinitely paginated" Backbone collection,
 * IE, you can keep adding the contents of the next page to the collection
 * and only fetch the next page when you need to. Basically this is how
 * the Facebook news feed works - you scroll to the bottom and then it makes
 * a call to the server to get the next set of results.
 *
 * @author  Jason Raede <jason@torchedm.com>
###

# Uncomment this line and indent everything below it if you use require.js
#define ['backbone', 'underscore'], (Backbone, _) ->
class InfinitelyPaginatedCollection extends Backbone.Collection
	resultsPerCall:20
	sortColumn:'id'
	sortDirection:'DESC'

	comparator: (model1, model2) ->
		if model1.get(@sortColumn) < model2.get(@sortColumn) then return 1
		else if model1.get(@sortColumn) is model2.get(@sortColumn) then return 0
		else return -1

	fetchPreviousModels: (options) ->
		# Models should already be sorted, so we just get the @sortColumn value for the first one
		# and use that as the `before` value to pass to the server
		
		firstModel = @at(0)

		if firstModel
			before = firstModel.get(@sortColumn)
		else 
			before = null

		options = if options then _.clone(options) else {}
		if options.parse is null then options.parse = true
		success = options.success
		
		options.data = 
			before:before
			results_per_call:@resultsPerCall

		options.success = (resp) =>
			@add(resp, options)
			if success then success(@, resp, options)
			@trigger 'newPage', @, resp, options

		@sync('read', @, options)

	###
	 * Make a call to the server to get the models after the most recently fetched model
	###
	fetchNextModels: (options) ->

		# Models should already be sorted, so we just get the @sortColumn value for the last one
		# and use that as the `after` value to pass to the server
		
		lastModel = @at(@length - 1)

		if lastModel
			after = lastModel.get(@sortColumn)
		else
			after = null

		options = if options then _.clone(options) else {}
		if options.parse is null then options.parse = true
		success = options.success
		
		options.data = 
			after:after
			results_per_call:@resultsPerCall

		options.success = (resp) =>
			@add(resp, options)
			if success then success(@, resp, options)
			@trigger 'newPage', @, resp, options

		@sync('read', @, options)