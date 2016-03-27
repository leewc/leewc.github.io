---
layout: post
title : How to have multiple InfoWindows in Google Maps
excerpt: Allowing each marker to have it's own info window
date: 2016-01-31 01:56
categories: articles
comments : true
share: true
tags: [tutorial, javascript]
---

*This is part of a series of posts that I wanted to do around late October last year, I finally got to it.*

When I was doing an [assignment in Internet Programming](https://github.com/leewc/apollo-academia-umn/tree/Internet_Programming/4131-Internet_Programming/assignment3-google-maps-api) last semester, we were given the task of using the Google Maps API. This assignment also required the use of custom markers, and to have Info Windows that are displayed upon clicking the multiple custom markers.  

The Google Maps API example for [InfoWindows](https://developers.google.com/maps/documentation/javascript/examples/infowindow-simple) was useful in displaying only one info window (a window with additional information if a marker is clicked), and this led me to thinking I could instantiate a new InfoWindow and add an event listener to it. 

Something like this:

{% highlight javascript %}
	//this is done inside a for-loop that goes through an array of data
	var infowindow = new google.maps.InfoWindow({
	  content: contentString
	});
	//marker is the marker object in the array
	marker.addListener('click', function() {
  	infowindow.open(map, marker);
	});
{% endhighlight %}

However, this led to the InfoWindow only displaying information about the last item in the array of objects, no matter which marker I clicked.

After a bit of head scratching and Google-fu, I then realized I had stumbled onto an issue caused by **closures**.

## The actual problem

JavaScript has a language construct called closures, which capture references to external variables. What was happening here was that the function that was added to the marker as a listener would only hold the reference to the last 'infowindow' instance, due to closures. Another way to wrap your head around this is that the functions are only invoked when the event is actually called, which by then the `Infowindow` to be opened is the last item in the data array we iterated through. Coming from a mostly-Java background, this confused me for a little bit as the same kind of code in Java would not have this 'weird' issue of all custom markers (in an array) only displaying information from the last item in the data array.

## The solution

Thanks to trusty [StackOverflow](http://stackoverflow.com/questions/7044587/adding-multiple-markers-with-infowindows-google-maps-api) and some understanding of what closures are, there are 2 solutions to avoiding the side effect created by JavaScript closures.

1. Adding the Infowindow object to the marker itself, using a key

We can explicitly create a reference to a specific infowindow by assigning it to a custom key to the marker object, and then later retrieving it by using that reference when the marker is clicked and the event is fired. By assigning the infowindow to a marker property, each marker can have it's own infowindow.

This was how I approached the problem, with the relevant sample code.

	{% highlight javascript %}
	//create a marker object first, or instantiate it by passing a JSON to the constructor.
	//this can be done inside a for loop

	var infowindow = new google.maps.InfoWindow({ //add relevant data here });

	//creates an infowindow 'key' in the marker.
	marker.infowindow = infowindow;

	//finally call the explicit infowindow object
	marker.addListener('click', function() {
		return this.infowindow.open(map, this);
	})

	// Alternate way of adding infowindow listeners
	google.maps.event.addListener(marker, 'click', function() {
	 	this.infowindow.open(map, this); 
	});

	{% endhighlight %}


2. Using anonymous function wrapping

We can have the infowindows and the markers stored separately as well, all we have to do is add an additional anonymous function that is returned by the function that is called on click event. This will cause JavaScript to evaluate the value of the 'key' only when the click event is fired, avoiding the value of 'key' to be bound to only the last value when used in a for-loop. The anonymous function wrapping avoids the value of key to be prematurely bound.

	{% highlight javascript %}
	//store all infowindows into an array called 'infowindows'
	//store all markers into an array called 'markers'

	 google.maps.event.addListener(markers[key], 'click', function(innerKey) {
      return function() {
          infowindows[innerKey].open(map, markers[innerKey]);
      }
    }(key));

	{% endhighlight %}


Option 1 probably appeals to programmers coming from a Java background, at least in my opinion. When I just started out on JavaScript programming I found the whole wrap this into that function around a callback and perform function passing a little more intimidating, that is till I realized it was functional programming and it was beautiful in it's own way. 

Couldn't have done it without those answers that were contributed by other developers. I highly recommend you read that answer for even more info. 

Code for my assignment can be [found here](https://github.com/leewc/apollo-academia-umn/blob/Internet_Programming/4131-Internet_Programming/assignment3-google-maps-api/maps_custom.js), as part of the `apollo-academia` repository.