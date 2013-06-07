infinite-backbone-collection
============================

Backbone.Collection subclass for infinite pagination a la Facebook news feed.

Note that you need to implement server-side handling for retrieving the next/previous results set. 
## Configuration options:

* resultsPerPage - gets sent as "results_per_page" in the `data` object in the AJAX request
* sortColumn - the property of the Backbone.Model that sorting should be done by. This should also be implemented in the same way on the server side
* sortDirection - "DESC" or "ASC". Again, should be implemented in the same way on the server side

## Usage
Just extend this object instead of the Backbone.Collection object, set the resultsPerPage, sortColumn, and sortDirection properties on the object, and then use fetchNextModels and fetchPreviousModels methods to add models to the collection.

## Example Server-side Code (PHP)

	public function get_collection() {
		$results_per_call = $_GET['results_per_call'] ?: 20;
		if(!empty($_GET['before'])) {
			$comparator = 'before';
			$compared_to = $_GET['before'];
		}
		else if(!empty($_GET['after'])) {
			$comparator = 'after';
			$compared_to = $_GET['after'];
		}
		else {
			$comparator = null;
			$compared_to = null;
		}

		if($comparator == 'after') {
			$results = $db->query("SELECT * FROM table WHERE `timestamp` < ? ORDER BY `timestamp` DESC", $compared_to)->limit($results_per_call)->get();
		}
		elseif($comparator == 'before') {
			$results = $db->query("SELECT * FROM table WHERE `timestamp` > ? ORDER BY `timestamp` DESC", $compared_to)->limit($results_per_call)->get();
		}
		else {
			$results = $db->query("SELECT * FROM table ORDER BY `timestamp` DESC")->limit($results_per_call)->get();
		}

		echo json_encode($results);
	}
