function search() {
	var value = $('#mainSearch').val();

	if(value) {
		$('#searchOptions input:checked').each(function() {
		    var name = $(this).attr('name'),
		    	url = 'http://localhost:3000/search/' + name,
		    	data = { search : value };

	    	sendRequest(name, url, data);
		});
	}
}

function sendRequest(name, url, data) {
	$.ajax({
		url: url,
		type: 'POST',
		data: JSON.stringify(data, null, 2),
		dataType: 'html',
		contentType: 'application/json',

		success: function(data, status, xhr) {
			console.log('success');
			$('#searchResults #' + name + ' .' + name + '-results').html('');
			$('#searchResults #' + name).show();
			$('#searchResults #' + name + ' .' + name + '-results').append(data);
			setHovers();
		},

		error: function() {
			console.log('error!');
		}
	});
}

function setHovers() {
	$(".flickr-image").mouseleave(function() {
		$(this).find(".flickr-content").stop().slideUp(250);
	});

	$(".flickr-image").mouseenter(function() {
		$(this).find(".flickr-content").stop().show().slideUp(0).slideDown(250);
	});
}

$(function() {
	$('#mainSearch').keyup(function(e){
			console.log('event!');
	    if(e.keyCode == 13)
	    {
	        search();
	    }
	});
});