---
layout: post
title: Out of Stock - An IKEA Stock Checker
excerpt: Using Puppeteer, Headless Recorder and NodeJS to check if IKEA furniture (or meatballs) are in stock
modified: 2020-12-10
categories: articles
tags: [puppeteer, js, javascript]
comments: true
share: true
readtime: true
date: 2021-03-15
---

## Prelude

> Update on stock availability at stores:
> .. we are currently experiencing supply delays due to COVID-19 
> - [FAQ](https://www.ikea.com/us/en/customer-service/faq/)

Recently I've moved and wanted to buy some furniture from IKEA. However due to COVID-19 the global supply chains have been impacted such that essentials for a new home are out of stock*.
Plus, you'll notice the guidance from IKEA's FAQ above is to use their app to check for in-stock items at your local store. 

But it seems like the only proper way to check if an item is in stock is to add an item to cart, checkout, enter your ZIP code and if you're lucky, you get an option to pick a delivery date. 

- (Side note: Yes, I realize this is a real first-world problem, not having furniture in stock at IKEA. Be sure to at least find ways to support the frontliners in the healthcare system, your local restaurants, tip the hard working delivery drivers and essential workers in the service industry.)

### TL;DR 

(for more experienced devs looking to see how I achieved certain things, feel free to speed read and look at keywords in **bold**)
- You can also just skip the rest of this blog post if you just want to read [the code here](https://github.com/leewc/ikea-puppeteer/blob/main/ikea.js).


## Intro 

So instead of manually checking if an item is in stock every few days or so (what fun is that?), I decided to learn how to use Puppeteer to write a Node JS script that would programmatically control Chromium (open source project that Google Chrome is based on) to add an item to cart, type in the ZIP code we want and check if there's the item we want in stock.

[Puppeteer](https://github.com/puppeteer/puppeteer) is a browser automation and testing framework that allows you to script and manipulate an instance of Chromium.
We'll also use [Headless Recorder](https://github.com/checkly/headless-recorder) (formerly Puppeteer Recorder) to jumpstart our automation by recording your browser actions to generate a script. If an item is in stock, have the app send an email.

Before diving in I wanted to mention I'm **not very skilled at JS** and best-practices, and that this was meant to be a quick script to automate a manual process for individual use, so some parts are a hacky. As such you might see better ways of doing certain things, or me breaking some best practices. I'm always interested in learning, so feel free to leave some feedback below. 

## Setting the Stage

We'll need the following:
 - Node JS (to run the app)
 - NPM (install Node packages like Puppeteer and Nodemailer)
 - Puppeteer (to automatically visit IKEA.com and check for in-stock/delivery items)
 - Nodemailer (to send email via SMTP)
 - Headless Recorder (Chrome Extension)
 - Chrome (to install the extension)

Before starting to automate, similar to User acceptance testing, let's note what we want to do. It's helpful to have some idea in mind what you want to achieve before using Headless Recorder to generate the script. This is what we want to automate: 

1. Open Chromium and visit specific product links, for example: [this random mirror](https://www.ikea.com/us/en/p/stockholm-mirror-walnut-veneer-60249960/) 
2. Click on the 'Add to bag'
3. Either add more items to the bag, or click on 'Continue to bag'
	- The reason I say either is you get to decide if you want to be notified when at least one item you want is in-stock and deliverable, or only to be notifed when *all* are in stock. 	  
	- Here in the US we pay a flat fee for shipping, so it's something to think about!
4. At the shopping bag page, we will 'continue to checkout'
5. We enter our zipcode and hit 'Calculate Delivery Cost'
6. If the website errors out or tells us some items are out of stock, do nothing.
    - (their backend API appears to throw a `500 Service Unavailable` on occasion if there is only one item in your bag and it's out of stock)
7. If the website allows you to pick 'Regular Delivery', notify us. 

With that test plan/script out of the way, here's what the end result will look like (GIF below, might take a few seconds to load): 

![GIF Demo of Ikea Out of Stock Checker](/images/articles/puppeteer-ikea/ikea-oos.gif)

Took some inspiration also from how to get started with Puppeteer from [this article](https://www.toptal.com/puppeteer/headless-browser-puppeteer-tutorial).

I also highly recommend this post on [building a scheduled news crawler](https://levelup.gitconnected.com/building-a-scheduled-news-crawler-with-puppeteer-d02a7919bdbe).

## Overture (Composing the Script)

### Jumpstarting the script 

I love doing less work whenever I can, so I **installed the Headless Recorder extension on my Chrome and started recording my steps**. It won't generate perfect code, but it's good enough to get iterating and results. Hit 'Record' on the extension and run through your scenario above, you should get something like these:

<img src="/images/articles/puppeteer-ikea/headlessrec-rec.png" alt="Image of Headless Recorder recording" width="450"/>

<img src="/images/articles/puppeteer-ikea/headlessrec-done.png" alt="Image of Headless Recorder done recording" width="450"/>

The resulting script should be something like below (this is also on [Github](https://github.com/leewc/ikea-puppeteer/blob/main/snapshots/ikea-1-headless-gen.js)).

```js
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  
  const navigationPromise = page.waitForNavigation()
  
  await page.goto('https://www.ikea.com/us/en/p/stockholm-mirror-walnut-veneer-60249960/')
  
  await page.setViewport({ width: 1792, height: 953 })
  
  await page.waitForSelector('.js-buy-module > .range-revamp-buy-module__buttons > .range-revamp-buy-module__buttons--left > .range-revamp-btn > .range-revamp-btn__inner')
  await page.click('.js-buy-module > .range-revamp-buy-module__buttons > .range-revamp-buy-module__buttons--left > .range-revamp-btn > .range-revamp-btn__inner')
  
  await page.waitForSelector('.rec-modal > .rec-modal__content > .rec-modal__hero > .rec-added-to-cart__hero > .rec-text')
  await page.click('.rec-modal > .rec-modal__content > .rec-modal__hero > .rec-added-to-cart__hero > .rec-text')
  
  await navigationPromise
  
  await page.waitForSelector('.shoppingbag__headline > .checkout__wrapper > .checkout > .cart-ingka-btn > .cart-ingka-btn__inner')
  await page.click('.shoppingbag__headline > .checkout__wrapper > .checkout > .cart-ingka-btn > .cart-ingka-btn__inner')
  
  await navigationPromise
  
  await page.waitForSelector('.zipin #zipcode')
  await page.click('.zipin #zipcode')
  
  await page.type('.zipin #zipcode', '98109')
  
  await page.waitForSelector('.zipin > form > .\_Rfx6_ > .button > .button__text')
  await page.click('.zipin > form > .\_Rfx6_ > .button > .button__text')
  
  // if Toastify
  await page.waitForSelector('.Toastify__toast-container > .Toastify__toast--error > .button')
  await page.click('.Toastify__toast-container > .Toastify__toast > .button')
  
  await browser.close()
})()
```

#### What was done?

Headless recorder generated a script emulating our actions. Taking a quick look, it is instructing the use of `puppeteer`, and to make use of `await`, everything is wrapped
in an anonymous `async` function that is immediately invoked. This is known as an IIFE (Immediately Invoked Function Expression). [Mozilla docs] (https://developer.mozilla.org/en-US/docs/Glossary/IIFE). 

While not immediately important, it's good to know that `await` is a preferred method of handling async programming to avoid callback hell, or to avoid a continuous `then().then().then()` call pattern. (At least from what I've learnt while doing this project), I find [this article on Async await quite useful to understand async awaits](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Async_await). From a Java background where you can simply `Thread.sleep()` or spin up a threadpool to work and `block` for that thread to complete, JS has an event loop and doesn't wait for Async functions to complete, unless `await` is explicitly used. Paraphrasing the docs, `await` can be put in front of any async promise-based function to pause your code until the promise fulfills, then return the resulting value. 

Before moving forward, it's a good idea to watch what Headless recorder, um recorded. So to do that, we'll need to **change the `await puppeteer.launch()` flags 
to *not* be headless**. Since it's true by default, we wouldn't be able to debug/watch what is going on. We'll also need to slow down Puppeteer a little so we can watch
exactly what's going on. To do so, you'll want to change `puppeteer.launch()` to this:

```js
  // debug mode
  const browser = await puppeteer.launch({headless: false, slowMo: 100})
```

This will tell Puppeteer to open up Chromium with a display, and slow things down by 100ms (feel free to increase it). 

But wait, you'll realize I forgot to show you how to run the script!

If you're planning to copy this to another machine/publish it to NPM, then you'll want to `npm init`, answer some questions, and then only go ahead and install `puppeteer`. 
Initializing will generate a `package.json` file that contains information about your NodeJS script!

Execute the following:

```
npm init #only if you want a package.json
npm install puppeteer
```

After that, to run the script, simply save the script above as `ikea.js`, then `node ikea.js` (or just `node ikea`). 

You should see Chromium's blue icon pop up, and find yourself trying to check out that random mirror we got!

This is a good start. Now we need to extend this to what we planned next: handling all scenarios, support add to cart for multiple items,
trying to check out. This is also a good time to refactor the code since it's quite procedural at the moment. 

### Adding the other scenarios

Sweet. Now with that out of the way, let's then **use Headless recorder to generate the other use-cases: Item is in stock, or with many items in the bag and some are out of stock, you'll get told to remove the items.**

You can then combine these generated scripts and start refactoring there. What I noticed:

1. We can refactor these procedural scripts into reusable methods like `addToCart`, and `beginCheckout`.

2.  After checking out and entering a zipcode, based on what I did:
  - If an item is in stock, Puppeteer waits for `await page.waitForSelector('.homedelivery #REGULAR')` before clicking on the option.
  - If an item is out of stock, Puppeteer clicks on the `await page.click('.homedeliveryoptions__option > .stockavailability > .stockavailability__recalculate > .button > .button__text')` button. 
  - If 'Something went wrong', Puppeteer clicks on the `'.Toastify__toast-container > .Toastify__toast--error > .button'`. 
  
3. It was at this point I ran into my first snag, since IKEA only displays certain elements if it is in stock (and most of the time, it'll be out of stock, otherwise why are we doing this?). I needed to tell Puppeteer to wait for an element to be present, or move on if it is not present. 

Diving into (3), I started reading about what properties `waitForSelector` allows, and decided to add a timeout: 

```js
  if (await page.waitForSelector('.Toastify__toast-container > .Toastify__toast--error > .button', {timeout: 5000}) !== null) {
    // Case: IKEA's backend decides to throw an error. Out of stock.
	await page.click('.Toastify__toast-container > .Toastify__toast > .button')
    console.log("Out of stock :(")
  } else if (await page.waitForSelector('.homedeliveryoptions__option > .stockavailability > .stockavailability__recalculate > .button > .button__text')) {
    // Some items in the cart are out of stock, on stock availability recalcuate
    await page.click('.homedeliveryoptions__option > .stockavailability > .stockavailability__recalculate > .button > .button__text')
    console.log("Some items are out of stock..."); 
  }else if (await page.waitForSelector('.homedelivery #REGULAR') !== null) {
    // Items are in stock!
  } else {
    // Something we didn't account for
  }
```

**Few tips**:

1. Chrome's developer tools ('right-click' > 'Inspect Element') are super helpful here to make sense of what Headless Recorder captured. How I approached refactoring it was adding comments to each generated code block. 

2. Attaching to the 'Console' will give you an insight as to what's going on behind the scenes too: See [this Google documentation](https://developers.google.com/web/tools/puppeteer/debugging). 
    - `page.on('console', msg => console.log('PAGE LOG:', msg.text()));`

You can check out my state of the script at this point on [Github](https://github.com/leewc/ikea-puppeteer/blob/main/snapshots/ikea-2-scenario.js).
 - Nothing too much has happened yet, all I did was work backwards and understand what Headless Recorder saw, and annotated the code, and pushed it around into ugly chunks of 'if-else' checks.

**Something I realized after getting the script working the way I intended: I didn't have to capture all the happy/unhappy cases**. I could simply wait for the 'in stock' Page elements to show up, otherwise, give up and try again later. But, as I was fixated on learning how to handle all scenarios gracefully, I pushed ahead. I kept this logic here for completeness sake. (This is why I told you I did it as a learning exercise) 

### Refactoring.

We'll then move code around such that we can reuse certain steps as methods, the pseudo javascript code of what we want:

```
function main() {
	detailPageLinks = ['https://www.ikea.com/us/en/p/stockholm-mirror-walnut-veneer-60249960/'] //array of IKEA detail page links
 	for (detailPageLink of detailPageLinks) {
		page.goTo(detailPageLink);
		addToCart()
	}
	beginCheckout()
	// Logic to check if an item is in stock happens here
	// notifyEmail() //do this later
}

function addToCart() {
	// Code to add an item to cart goes here
}

function beginCheckout() {
	// Code to checkout goes here
}

```

I ran into my second snag here coming from a Java background. I naively cut and paste code into those functions (wrapped inside the IIFE, i.e the `(async() => {}();)` expression - because I didn't realize I didn't have to do this, if I was already calling these functions from one), VSCode told me adding `await` was of no effect since `await` only works with `async` functions. Thinking adding `async` to the method signature `addToCart` was it. Like so: 

```
// **non-working code below**
// https://developer.mozilla.org/en-US/docs/Glossary/IIFE
async function addToCart(page, detailPageLink) {
  (async() => {
    console.log("Going to add to cart");
	//Puppeteer code here.
  })();

```

Then and I tried running the script again. This time, `addToCart()` would get interupted by `beginCheckout()`, which would then get stuck because we never managed to add an item to the cart. What gives?? **Turns out JavaScript was doing what we told it to do, make an async function**. 
 - By definition, async functions do not block. All the `await` inside the `async` IIFE would block while the thread was executing the method, but the main running process itself just gets a `Promise` from `addToCart`. Doing `await addToCart`, would not work because `addToCart` would have just returned the `promise` from the IIFE.

The fix was to add an `await` before the IIFE. 

```
// https://developer.mozilla.org/en-US/docs/Glossary/IIFE
async function addToCart(page, detailPageLink) {
  // need one await here to 'block'
  await (async() => {
    console.log("Going to add to cart");
	//Puppeteer code here.
  })();

```

In hindsight I could have just not done the immediately invoked function. But you know, hindsight 20/20, and I got to learn about this. [This article about async await](https://bluepnume.medium.com/learn-about-promises-before-you-start-using-async-await-eb148164a9c8) was also very helpful in understanding what was going on. 

So at this point we have a few ways for waiting for an element to show up on IKEA's website. 

1. `waitForSelector`
	- There is a 'visible' flag, in which will ensure we only move to the next step when an item is actually visible.
2. `waitForNetworkIdle`
    - This will block the Puppeteer execution until there are no longer any network events. While great in practice, you might miss out on elements that are only onscreen/visible for a limited time (like toast notifications/slide outs etc).
3. `page.goto("link", {waitUntil: 'networkIdle0'})`
	- This flag ensures Puppeteer waits until there's 0 network connections for at least 500 ms, allowing it to consider navigation as 'finished'. There is also a lighter `networkIdle2`, that moves to the next step as long as there are <2 connections. More info [here](https://github.com/puppeteer/puppeteer/blob/main/docs/api.md#pagegotourl-options)

However, upon turning 'headless' back 'on' and not with any `slowmo`, the expected elements were not showing up, and attempting to 'click' on the elements eventually caused a timeout and an exception was thrown.
 - It later turned out that the script fails when IKEA is loading slowly for me. By the time the toast shows up, Puppeteer would have gave up waiting. 

While `waitForNetworkIdle` was OK, the issue here would be the toast could have disappeared by the time the website finished loading. So what I did instead was a **hack/workaround was to simply slow down Puppeteer such that the site/toast would have showed up by then. This worked out for me since I didn't really need any faster web scraping.**

[This](https://github.com/leewc/ikea-puppeteer/blob/main/snapshots/ikea-3-working.js) is what our script looks like at this point.

### Optimizations

- I didn't like how some instructions generated by Headless Recorder looked line, and noticed I could simply `await page.goto('https://www.ikea.com/us/en/shoppingcart/') ` instead of clicking on the 'Continue to bag' button.
- I refactored the code around further to make it such that we actually have functions.
	- This [StackOverflow](https://stackoverflow.com/questions/22536385/setting-a-variable-to-get-return-from-call-back-function-using-promise) post helped with understanding how to get a return value from the callback function.
- I cleaned up the generated code a little more by using the class names or IDs already available, for example, it looks like IKEA leverages some form of UI testing that uses these kind of targets: `[data-test-target="add-to-cart-button"]` (Inspect element is really your friend here).

[This](https://github.com/leewc/ikea-puppeteer/blob/main/snapshots/ikea-4-no-email.js) is the final version we have before I added `node-mailer` to notify me when an item is in stock.

## Fugue (Testing)

Testing on Puppetteer is fairly easy, simply keep running the script, watch and make sure it's working, test the positive and negative, any other edge cases (what if the network times out? What if IKEA starts blocking your IP?) was fairly manual for me. 

That's one thing I like about UI automation is you get to see it live and happen in front of you, making the develop, test, iterate, test cycle super fast.

## Postlude (Deploying)

This was easy enough, I just had to copy the file to my old college laptop (that I have running as a Plex media server), open `screen` and run `node ikea.js` after running `npm install` or manually installing the dependencies if I didn't have a `package.json`. 

But I also needed the script to email me while it was in stock. Or at least some way of notifying me. So I used `nodemailer`, grabbed an app password for my gmail and had the script email me whenever one of the links I wanted was in stock.

**You can find the working version here**: https://github.com/leewc/ikea-puppeteer/blob/main/ikea.js

What's next? 

- Perhaps have `nodemailer` notify you when the script runs into an exceptional case?
- Dockerize and deploy to the Cloud (Heroku, AWS, GCP)? 
  - Minor note on this, since many websites do ban traffic coming from a datacenter (which is why some websites block you when you're on corporate intranet/VPN), this might be more trouble than worth.
- Actually have the script purchase the item for you, but with guardrails to avoid any bugs that end up with 42 sofas due to a for-loop bug?
- Frontend UI? WebService?

## Fin.

Unsurprisingly, with my procrastination and life in general, IKEA has since updated the website (around Jan 15 2020), thereby breaking my script in the process. I've fixed it. Really good reminder to also set up a process that emails you when things break. Since I only found out after `SSH`-ing in to check on the status. I also decided to get rid of the out of stock prompt check as timing the 'toast' notification from IKEA was quite hard, given the element was not visible when it's in stock (but present), and when visible, I couldn't time/tell puppeteer to wait for it. It's not code I'm proud of, and I left a lot of comments for my learning, but it works ;) 

Have to plug this article again, on [building a scheduled news crawler](https://levelup.gitconnected.com/building-a-scheduled-news-crawler-with-puppeteer-d02a7919bdbe), I think it's very similar though I only found it nearing the end of my script writing!
