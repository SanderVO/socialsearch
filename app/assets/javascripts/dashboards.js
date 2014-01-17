function search() {
	var value = $('#mainSearch').val();

	if(value) {
		$('#searchOptions input:checked').each(function() {
		    var name = $(this).attr('name'),
		    	url = 'http://localhost:3000/search/' + name,
		    	data = { search : value };

	    	sendRequest($('#searchResults #' + name), url, data);
		});
	}
}

function sendRequest(target, url, data) {
	$.ajax({
		url: url,
		type: 'POST',
		data: JSON.stringify(data, null, 2),
		dataType: 'html',
		contentType: 'application/json',

		success: function(data, status, xhr) {
			console.log('success');
			target.html('');
			target.show();
			target.append(data);
		},

		error: function() {
			console.log('error!');
		}
	});
}