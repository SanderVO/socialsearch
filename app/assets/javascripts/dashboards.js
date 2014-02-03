var animation_delay = 300;
var column_count = 4;
var current_page = 0;

$(document).ready(function() {
	$(':checkbox').checkbox('check');

	$('#options_button').click(function(){
		$('#searchOptions').slideToggle(300);
	})

	$('#searchForm').submit(function(e) {
		e.preventDefault();
		searchAll();
		return false;
	});
});

$(document).scroll(function(e){
	$('.searchResultList.active').each(function() {
		var name = $(this).attr('id'),
			counter = 0;

		if ($(this).css('display') == "block" && $(this).find("ul li.error").length == 0 && element_in_scroll("#" + name + " .searchData ul li:last")) {
			if($('#' + name + ' .loader').css('display') != "block") {
				getNextResults(name, counter);
				counter++;
			}
    	}
	});
});

function getNextResults(name, counter) {
	console.log('test');
	var value = $('#mainSearch').val(),
		total = $('#searchOptions input:checked').length,
		limit = $('input#limit').val();

	if(value && total > 0) {

	    var url = '/search/' + name,
	    	token = $('#' + name + ' .searchData ul li:last').attr('nextpagetoken'),
	    	token2 = $('#' + name + ' .searchData ul li:last').attr('secondpagetoken'),
	    	data = { search : value, nextpagetoken : (token ? token : ''), secondtoken: (token2 ? token2 : '') };

		if(isNaN(limit) || (!isNaN(limit) && limit <= 0)) limit = 10;
		else if(limit > 100) limit = 100;

		$('#' + name + ' .loader').show();

		sendRequest(name, url, data, counter, total, limit);
	}
}

function element_in_scroll(elem)
{
    var docViewTop = $(window).scrollTop();
    var docViewBottom = docViewTop + $(window).height();
 
    var elemTop = $(elem).offset().top;
    var elemBottom = elemTop + $(elem).height();
 
    return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
}

function changeToVideo(id) {
	$('#' + id + ' .youtube-video-thumb').remove();
	$('#' + id).append('<iframe height="265" src="//www.youtube.com/embed/' + id + '" frameborder="0" allowfullscreen></iframe>');
}

function simulateSearch(text){
	console.log('Search for '+text);
	$('#mainSearch').val('');
	for ( var i = 0; i < text.length; i++ ){
		var l = text.charAt(i);
		console.log("Letter: "+l);
		$('#mainSearch').val($('#mainSearch').val()+l);
	}
	searchAll();
}

function searchAll() {
	var value = $('#mainSearch').val(),
		counter = 0,
		total = $('#searchOptions input:checked').length;

	if(value && total > 0) {
		$('#searchResults .searchData').html('');
		$('#searchResults .searchResultList').removeClass('active').hide();
		total > column_count ? $('.nextLink').show() : $('.nextLink').hide();

		current_page = 0;

		$('#searchResults .searchData').html("");
		$('.dialog.notice').slideUp(300);

		var delay = animation_delay;

		$('#searchOptions input:checked').each(function() {
		    var name = $(this).attr('name'),
		    	url = '/search/' + name,
		    	limit = $('input#limit').val(),
		    	data = { search : value };	    

	    	
	    	// build class name. Can be one or more of these: (active last loading)
	    	var class_name = 'active loading';
	    	$('#searchResults #' + name + ' .loader').show();
	    	if(counter == column_count-1){
	    		class_name += ' last';
	    	}
	    	$('#searchResults #' + name).addClass(class_name);

	    	// fade column in if needed
	    	if(counter < column_count){
	    		$('#searchResults #' + name).fadeIn(delay+=100);
	    	}

	    	if(isNaN(limit) || (!isNaN(limit) && limit <= 0)) limit = 10;
	    	else if(limit > 100) limit = 100;

	    	//send request
	    	sendRequest(name, url, data, counter, total, limit);

	    	counter++;
		});

				// move input bar to nav
		$("#searchForm, #searchOptions, .searchData").hide();
		$("#searchForm").detach().appendTo('#search-bin');
		$("#searchOptions").detach().appendTo('#searchForm .input-group');
		$("#searchForm,#options_button").hide().removeClass('hidden').fadeIn(800);
		$('.jumbotron').slideUp(300);
		$('.container-fluid').css('background','none').css('color','#333');

		$('.previousLink').hide(animation_delay);
		if(counter <= 4) $('.nextLink').hide(animation_delay);
		else $('.nextLink').show(animation_delay);
	}
}

function sendRequest(name, url, data, counter, total, limit) {
	$.ajax({
		url: url+"?limit="+limit,
		type: 'POST',
		data: JSON.stringify(data, null, 2),
		dataType: 'html',
		contentType: 'application/json',

		success: function(data, status, xhr) {
			$('#searchResults #' + name).removeClass('loading');

			$('#searchResults #' + name + ' .' + name + '-results').show(0).append(data);
			var delay = animation_delay
			$('#searchResults #' + name + ' .' + name + '-results ul li').each(function(){
				if($(this).css('display') != "block"){
					$(this).slideDown(delay+=100);
				}
			})

			setHovers();
			$('.searchdata iframe').load(function(){
				$(this).find('#outerWidgetContainer').css('width', 'auto');
			});
			$('#searchResults #' + name + ' .loader').hide();
				//$('#searchResults .searchResultList:lt('+column_count+')').show();
			
		},

		error: function() {
			console.log('error loading data from '+name+'!');
			$('#searchResults #' + name).removeClass('loading');
			$('#searchResults #' + name + ' .' + name + '-results').html("<li>No results found</li>");
			$('#searchResults #' + name + ' .' + name + '-results').show(300)
			$('#searchResults #' + name + ' .' + name + '-results ul li').show(300)
		}
	});
}

function showNext() {
	current_page+=1;
	showPage(current_page);
}


function showPrevious() {
	current_page-=1;
	showPage(current_page);
}

function showPage(pagenr){
	console.log("Showing page "+pagenr);
	var divs = $("#searchResults .searchResultList.active");
	var total = divs.length;
	var delay = animation_delay;
	var npages = Math.ceil(total/column_count);

	var start = (pagenr) * column_count;
	var end = start + 4;
	console.log(" >> "+pagenr + " - "+npages);
	console.log(" >> "+start+" - "+end);
	$.each(divs, function(index) {
		if(index >= start && index < end){
			console.log(" >> Showing "+$(this).attr("id")+" on index "+index);
			$(this).show(delay+=100);
			//$(this).next().animate({'margin-left': '-'},delay+=100);
		}else{
			console.log(" >> Hiding "+$(this).attr("id")+" on index "+index);
			$(this).hide(delay+=100);
			//$(this).next().animate({width: '25%'},delay+=100);
		}
	});

	console.log(npages+" - "+pagenr);
	if(npages == 1 || pagenr == 0){
		$('.previousLink').hide(animation_delay);
		console.log(" >> Hiding previous link");
	}else{
		$('.previousLink').show(animation_delay);
		console.log(" >> HShowing previous link");
	}

	if(npages == 1 || pagenr >= npages-1){
		$('.nextLink').hide(animation_delay);
		console.log(" >> HHiding next link");
	}else{
		$('.nextLink').show(animation_delay);
		console.log(" >> HShowing next link");
	}
}


function setHovers() {
	$(".flickr-image").unbind('mouseleave');
	$(".flickr-image").mouseleave(function() {
		$(this).find(".flickr-content").stop().slideUp(250);
	});
	$(".flickr-image").unbind('mouseenter');
	$(".flickr-image").mouseenter(function() {
		$(this).find(".flickr-content").stop().show().slideUp(0).slideDown(250);
	});
	$(".tumblr-image").unbind('mouseleave');
	$(".tumblr-image").mouseleave(function() {
		$(this).find(".tumblr-content").stop().slideUp(250);
	});
	$(".tumblr-image").unbind('mouseenter');
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
