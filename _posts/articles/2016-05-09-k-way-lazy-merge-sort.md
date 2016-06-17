---
layout: post
title: K-way Lazy Merge Sort
excerpt: Sorting integers from k number of large files as lazy file streams
modified:
categories: articles
tags: [java, tutorial]
share : yes
comments : yes
image:
  feature: articles/mapreduce-thrift.png
date: 2016-05-09T16:58:52+00:00
---

Recently as part of my distributed systems assignment we were required to write a map-reduce framework that would perform Mergesort (or SortMerge) on a very large file. The central idea is to break the file 
up into chunks and then sort those chunks, before merging all the files into one. The project can be found [here](https://github.com/leewc/thrift-distributed-systems-projects/tree/master/a3-map-reduce).

Initially I wrote a simple merge that would read in 2 files as buffered streams and output the sorted file as another file, continuing the process until we have one file left. After rereading the 
requirements I realized we actually have to perform a k-way merge sort, where k is the number of files to read from in each merge process.

I also realized early on it might be best not to do everything in-memory, as intermediate files can possibly exceed the amount of RAM available. Or in the case of this Java project, exceed the amount of Java Heap
Space available. So in order for this algorithm to scale (think of sorting data files larger than the amount of RAM you have), we would need to lazy read in files, possibly as streams of data, sort the streams as we go, and flush to disk.
Since I didn't find any comprehensive article on how to sort streams of data in Java without doing it all in-memory or having them as a Linked List, I'd thought I'd write an article about the implementation of it [^1].


In this article I discuss how and why this might be useful, as well as how to do it.

# Why k-way merge?

For example in a typical MergeSort, if we split a 1024KB file into 64kb chunks, we'd have a total of 16 files to merge, that is, assuming each chunk is a perfect 16kb and we don't have to account for integers being truncated at the 
end of each chunk. (We did have to acocunt for this in our assignment.) The total number of merges to perform would be 15 merges \\( (n-1) \\). We get 15 from first performing 8 merges on the 16 files, 
then 4 merges on the 8 newly created files, then 2 more merges on those 4 files, and finally, 1 final merge to combine those 2 files, as those of you familiar with *mergesort* would have gathered.

The average run time of this [traditional](https://www.khanacademy.org/computing/computer-science/algorithms/merge-sort/a/overview-of-merge-sort) mergesort would be \\( O(n \log n) \\) where n is the number of items.
In this example where we perform mergesort \\(n-1\\) times, we have \\( O((n-1) • n \log n) \\) times, or simply, \\( O(n^2 \log n) \\).

How can we do better (in terms of run time) in this scenario where we have multiple files? 

Turns out we can write a \\(k\\)-way merge that has a worst case runtime[^2] of \\( O(k^2 • n) \\). This is useful for our use case, where we have a large number of sorted files that need to be merge. 

The runtime doesn't seem any better, you might have realized. However, on a practical level, a traditional 2-way merge sort across multiple files would create far too many intermediate files that we have to flush out to disk,
and then read in again. The less Disk I/O we have to do, the faster our algorithm can be. With \\(k\\)-way mergesort, if the number of files, \\(n\\), is less than \\(k\\), we won't even have anymore intermediate files!
As for cases where we have \\(n > k\\), we only need to perform mergesort \\(\frac{n}{k}\\) number of times.

# Implementation

I'll cover the merge part of the k-way sort merge, as you can sort multiple individual files with your favourite sorting algorithm, or just use Java's [`Collections.sort()`](https://docs.oracle.com/javase/8/docs/api/java/util/Collections.html#sort-java.util.List-) 
method if you don't mind doing the first part in-memory. Our current state of affairs is that we now have \\(n\\) number of files that all contain *sorted* integers, all of which are separated by a space. We want to perform
merge sort across \\(k\\) number of files at each run, without reading all the files in-memory, but rather as a stream. 

We can accomplish this by:

- Opening \\(k\\)-number of files as streams.
- Use a scanner to read the streams as integers (avoiding the need to perform low-level bit manipulation to evaluate what size integer we have, we'd have to read bytes to see if it's an ASCII space, 
  or if we're in the beginning or end of a number)
- A *PriorityQueue* that automatically sorts the streams, that way when taking a stream out of the queue we always have the smallest/largest number in the entire Queue.
- Another stream to write out the merged and sorted stream of integers, preferably a Buffered Stream for better disk I/O performance.

An issue I ran into was that we can never tell what the next number in a Scanner is, and we would have to solve that. I could have attempted to read an integer from all the integers into an array, compare for the smallest, 
write it out, and then read in another integer from the Scanner where I got the previous integer from, but that seems like a pain since I'd have to keep track of where I used the integer,
or if the Scanner was reaching the end, and then continuously sort each Scanner based on the Integer value I read in. Possibly ugly code too, especially if this was part of a larger project.

Using the powers of OOP and Reuse, or even Java subclassing, we can either extend a Scanner or write a custom class that automatically holds the next item in the Stream, let's call it a `PeekableScanner`. We'd also 
have to override/implement the comparator in `PeekableScanner` so that Java's Priority Queue knows how to sort the Scanners.

My PeekableScanner code below was adapted from [this PeekableScanner](http://stackoverflow.com/questions/4288643/how-do-i-peek-the-next-element-on-a-java-scanner/4288861#4288861).

~~~java
// @author: leewc
// Code for MyPeekableScanner.java

import java.util.Scanner;
import java.io.File;

//Thanks: http://stackoverflow.com/a/4288861/4512948
public class PeekableScanner implements Comparable<PeekableScanner>
{
    private Scanner scan;
    private Integer next;

    public PeekableScanner( File source ) throws Exception
    {
        scan = new Scanner( source );
        next = (scan.hasNextInt() ? scan.nextInt() : null);
    }

    public boolean hasNext()
    {
        return (next != null);
    }

    public Integer next()
    {
        Integer current = next;
        next = (scan.hasNextInt() ? scan.nextInt() : null);
	    return current;
    }

    public Integer peek()
    {
        return next;
    }

    @Override
    public int compareTo(PeekableScanner other) 
    {
    	//check if two numbers be equal or not.
    	if(peek() == other.peek())
    	    return 0;
    	else if(peek() > other.peek())
    	    return 1;
    	else // if(next < other.next)
    	    return -1;
    } 
}

~~~

Alright, now that we got our PeekableScanner down, we need the implementation of \\(k\\)-way mergesort that will take the stream that contains the smallest number from the PriorityQueue, write out the number,
advance the scanner, and finally put it back into the priority queue to repeat until we no longer have anymore scanners.

> **Why use a Priority Queue?** Well, the reason for this is because they're a flexible abstract data structure that I don't have to manually modify if I suddenly want numbers in say, descending order.
  The benefit is also thar in Java Priority Queue's are implemented as a heap, so they provide a nice \\(O( \log n)\\) time for [enqueue and deque methods](http://docs.oracle.com/javase/8/docs/api/java/util/PriorityQueue.html),
  making it an algorithm that's fast enough for our needs. I also wouldn't have to manually acocunt for the ordering of the streams, as having a Priority Queue automatically sorts all the streams thanks to the overloaded `compareTo` method.

Here's the code for my `merge` method, it takes a `MergeTask` object that contains the filename to write out to, and a list of files (containing the integers) to read from.

~~~java
// @author: leewc
// Method merge part of SortMerge class

    public boolean merge(MergeTask task) {
	Writer wr = null;
	try {
	    wr = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(task.output), "ascii"));
	    //open all the streams and stuff it into a priority q
	    PriorityQueue<PeekableScanner> q = new PriorityQueue<>(task.filenames.size());
	    for(String filename : task.filenames) {
		PeekableScanner pks = new PeekableScanner(new File(filename));
		q.add(pks);
	    }
	    
	    //poll for numbers and keep getting the next int
	    PeekableScanner smallest = q.poll();
	    //stop when there's nothing else
	    while(smallest != null) {
		if(smallest.peek() != null) {
		    //write the smallest int
		    wr.write(String.valueOf(smallest.next()));

		    //see if we should add it back if we still have it
		    //else get rid of it
		    if(smallest.hasNext()) {
			q.add(smallest);
		    }
		}
		//then check if q's front has numbers, if so add a space else don't	as it would mean we've reached the end of sorting	
		if(q.peek() != null) wr.write(" ");
		
	        smallest = q.poll(); //next thing
	    }
	    wr.close();
	    return true;
	}
	catch(Exception e) {
	    //in a perfect world, this would never happen
	    e.printStackTrace();
	    return false;
	}
    }
~~~

Output for the above method would be space-separated-integers like `1 3 5 6 9 10 200 500` written to the output file.
For completeness this is my MergeTask class, although you should just adapt the merge code to suit your use-case. Original Java files can be found [here](https://github.com/leewc/thrift-distributed-systems-projects/tree/master/a3-map-reduce/src).

~~~java
import java.util.List;

class MergeTask extends Task {
    List<String> filenames;
    public MergeTask(List<String> filenames, String output) {
	this.output = output;
	this.filenames = filenames;
    }

    @Override
    public String toString() {
	return "MERGE: " + filenames.toString() + " ---> " + output; 
    }
}

public abstract class Task {
    String output;
}
~~~

With all this we now have a nice lazy k-way mergesort function, where by \\(k\\) here in this example is determined by the number of files/streams open and placed in the priority queue. The algorithm held up well, as in 
our stress-testing we managed to merge over 50 files at 100 KB each without any problems. This algorithm will scale well on larger streams. Hopefully this will be helpful to you too!

*The title image above was part of a screenshot of running 17 VMs performing merge sort in a distributed environment.

**UPDATE 2016-06-16** : Added repository links to actual [project](https://github.com/leewc/thrift-distributed-systems-projects/tree/master/a3-map-reduce/) hosted publicly on GitHub!

[^1]: Coincidentally, this happened to be a software design question I was asked at an interview from a well-known and *very* large company, so it might come in handy for you too!

[^2]: Read this [wikipedia article](https://en.wikipedia.org/wiki/K-Way_Merge_Algorithms#Non-optimal) and this [StackOverflow question](http://stackoverflow.com/questions/11026219/why-is-k-way-merge-onk2) for a better explanation of the runtime than I can try to make.
