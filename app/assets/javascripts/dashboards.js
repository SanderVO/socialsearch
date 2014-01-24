function search() {
	var value = $('#mainSearch').val(),
		counter = 0,
		total = $('#searchOptions input:checked').length;

	if(value) {
		$('#searchResults .searchData').html('');
		$('#searchResults .searchResultList').removeClass('active').hide();
		total > 4 ? $('.nextLink').show() : $('.nextLink').hide();

		$('#searchOptions input:checked').each(function() {
		    var name = $(this).attr('name'),
		    	url = '/search/' + name,
		    	data = { search : value };

	    	counter++;

	    	sendRequest(name, url, data, counter, total);
		});
	}
}

function sendRequest(name, url, data, counter, total) {
	$.ajax({
		url: url,
		type: 'POST',
		data: JSON.stringify(data, null, 2),
		dataType: 'html',
		contentType: 'application/json',

		success: function(data, status, xhr) {
			$('#searchResults #' + name).addClass('active');

			if(counter == 4)
				$('#searchResults #' + name).addClass('last');

			$('#searchResults #' + name + ' .' + name + '-results').append(data);

			if(counter ==  total) {
				setHovers();
				$('#searchResults .searchResultList:lt(4)').show();
			}
		},

		error: function() {
			console.log('error!');
		}
	});
}

function showNext() {
	var divs = $("#searchResults .searchResultList.last").nextAll('.active');

	$("#searchResults .searchResultList").hide();
	
	if(divs.length > 4) {

	}
	else {
		var counter = 0;
		$.each(divs, function(index, value) {
			$(value).show();
			
			if(counter == 0)
				$(value).addClass('first');

			counter++;
		});
	}
}

function setHovers() {
	$(".flickr-image").mouseleave(function() {
		$(this).find(".flickr-content").stop().slideUp(250);
	});
	$(".flickr-image").mouseenter(function() {
		$(this).find(".flickr-content").stop().show().slideUp(0).slideDown(250);
	});
	$(".tumblr-image").mouseleave(function() {
		$(this).find(".tumblr-content").stop().slideUp(250);
	});
	$(".tumblr-image").mouseenter(function() {
		$(this).find(".tumblr-content").stop().show().slideUp(0).slideDown(250);
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
