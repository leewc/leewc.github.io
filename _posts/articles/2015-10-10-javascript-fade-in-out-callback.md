---
title : How to Fade Out/In in JavaScript Properly
excerpt: Of Transitions, Wait, and Callbacks in JS
date: 2015-10-10 01:17
tags: [tutorial, javascript]
---

Recently for a project I had to implement fade in and fade out functions in JavaScript, **without the use of JQuery**. It's amusing how much of the StackOverflow questions online focus on using JQuery, because it is admittedly easier to just call a library function. 

Of course, I have seen implementations of fade in and fade out methods in pure JavaScript, such as [this one](http://stackoverflow.com/questions/6121203/how-to-do-fade-in-and-fade-out-with-javascript-and-css), however, many of the articles I've found do not explain a means of fading out and then followed by fading in the next image. Admitted I've hit a very amateur snag in JavaScript programming, *thinking that all functions are synchronous* and execute after the previous instruction is complete. 

## The Problem

That is, naively, I had code like this:

{% highlight javascript %}
function transition(image){
	fadeOut(image);
	image.src = newImage.src;
	fadeIn(image);
}
{% endhighlight %}

where the `fadeOut` and `fadeIn` functions are something like so: (taken from the previously linked SO answer, credits to [Ibu](http://stackoverflow.com/users/560299/ibu))

{% highlight javascript %}
function fadeOut(element) {
    var op = 1;  // initial opacity
    var timer = setInterval(function () {
        if (op <= 0.1){
            clearInterval(timer);
        }
        element.style.opacity = op;
        op -= 0.1;
    }, 50);
}
{% endhighlight %}

{% highlight javascript %}
function fadeIn(element) {
    var op = 0.1;  // initial opacity
    var timer = setInterval(function () {
        if (op >= 1){
            clearInterval(timer);
        }
        element.style.opacity = op;
        op += 0.1;
    }, 10);
}
{% endhighlight %}
	

The basic idea was to fade out the image element, and then change it's source to point to the next image, and then fade it back in. Sounds easy right? Yes, except that nothing waits for the timer inside fadeOut to finish. Rather the fade in function is executed and messes up the transition with flickering images as both functions try to reduce and increase the opacity of the new image. We think that those functions will be asynchronous and nicely wait for the previous timer to finish. 

Those two functions work perfectly if they are triggered by other events separately, but when used back to back like I did, it'll flicker and not do what we intended it to do.

## The Solution

**Short Answer: Callbacks**

I figured I should write this post as many articles and posts regarding image fade in and out do not highlight the need for a callback or to nest the function inside, this is because they are usually considered as having separate events/buttons to trigger them, and not as a transition. 

A quick and dirty fix would be to nest the fade in function inside the fade out function and call that once the timer has been cleared, like so:

{% highlight javascript %}
function fadeOutAndfadeIn(image, newImage){
	var opacity = 1;
	var timer = setInterval(function(){
		if(opacity < 0.1){
			clearInterval(timer);
			//swap the image, and fadeIn, which is the same as above function
			image.src = newImage.src;
			fadeIn(image);
		}
		image.style.opacity = opacity;
		opacity -=  0.1;
	}, 50);
}
{% endhighlight %}

This works, but isn't very maintainable, what if you wanted to have another function for a transition, or not just change the image, but the dimensions as well? You'd have to either duplicate functions (violating the Don't Repeat Yourself (DRY) principle) or manually change the references or have some kind of if-else conditional. 

The better way to do it is via callbacks. Since functions are also a first class citizen, you can actually pass in a function as a parameter. And then call the function when you want to. This would let you execute whatever function you want called after the previous function has completed. This makes it general and very flexible.

{% highlight javascript %}
function fadeOutAndCallback(image, callback){
	var opacity = 1;
	var timer = setInterval(function(){
		if(opacity < 0.1){
			clearInterval(timer);
			callback(); //this executes the callback function!
		}
		image.style.opacity = opacity;
		opacity -=  0.1;
	}, 50);
}
{% endhighlight %}

After which you can use the function like so!

{% highlight javascript %}
fadeOutAndCallback(image,
	function(){
		image.src = newImage.src;
		fadeIn(image);
	}
);
{% endhighlight %}

What the above does is basically after the completion of the fade out transition (where the timer is cleared), the anonymous function is called which first changes the image source and then calls the fadeIn function. Flexible, reusable and not specifically hard-coded! 

## Side Note

If you're going to pass in a non-anonymous function as a callback, make sure you do not add the parentheses, as that will immediately invoke the function, and then take that return value (which might be undefined) as the call back. Here's an example.

{% highlight javascript %}
fadeOutAndCallback(image, myFunction()) 
//Wrong, it invokes myFunction(), and then takes the return value (undefined) which will be used as the callback  

//Right
fadeOutAndCallback(image, myFunction) //passes a function as a parameter
{% endhighlight %}

## What you shouldn't do.

Never use JavaScript's `wait()` for functions like this, as wait will block the entire execution of JavaScript, making it 'freeze' and become unresponsive. [Read more about it here](http://stackoverflow.com/questions/16873323/javascript-sleep-wait-before-continuing).

Lastly, **if you used JQuery** (which the whole point of this was to not use it), the `delay()` function would work as we would normally expect, as the callback logic has been abstracted out for us. [Here's a blog post](http://www.tigraine.at/2011/08/21/jquery-execute-once-animation-finished) that shows how to execute functions once an animation is finished. 