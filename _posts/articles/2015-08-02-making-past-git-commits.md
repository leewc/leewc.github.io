---
title : Making Git Commits in the Past
excerpt: Go back in time to make or edit commit.
date: 2015-08-02 21:51
tags: [tutorial, git]
---

Recently on a side project I've been working on I decided that I wanted to create a repository... 2 weeks later. This was because initially I felt I didn't have much code to begin with, no point keeping a version control of code that hasn't been written yet.. right?

By the time I decided to initialize a git for it, I decided I wanted to keep track of when I started, so I can have a gauge of the duration it took for me to develop the program, at least on whatever free off work hours I could find. Searching online didn't lead me to the answers right away, so here's how to create a commit back in time. 

Scenario: You suddenly want to change the timestamp of a commit in git to a time in the past. You don't want to resort to changing your system's clock, and you don't really want to (and well, can't) use a time machine to go back in time to make a commit.

The gist (haha) of it is to manually change the values for `GIT_COMMITTER_DATE` and also `GIT_AUTHOR_DATE`.

### If you have an empty repository.

If you have a brand new repository right after `git init` or cloning down from GitHub or GitLab or any other provider, open a new terminal and do:

	$ cd path/to/git/project`
	$ export GIT_COMMITTER_DATE="YYYY-MM-DD HH:MM:SS"
	$ export GIT_AUTHOR_DATE="YYYY-MM-DD HH:MM:SS"
	$ git commit -am 'Commit Message Here'

The format for dates can be done in the above fashion, or another format such as "Sat Aug 2 15:00", RFC 2822 and ISO 8601 date formats are valid. More information on the date format [here](https://www.kernel.org/pub/software/scm/git/docs/git-commit.html#_date_formats)

The reason why we need to do both committer and author date is because they mean different things in Git, and also GitHub/GitLab/other service providers. Usually they are stored as the same values, since if you do a commit without specifying a custom date for any of them the values default to 'now', which is the time you made the commit. The different, as [git-scm](http://git-scm.com/book/ch2-3.html) explains is that the *author* is the **person who originally wrote the work** while the *committer* is the **person who last applied the work**.

*A word of caution though*, if you decide to continue making more commits after making that commit in-the-past. *Close your terminal after making the in-the-past commit* or use another one! I made the mistake of making more commits in that terminal and they all used the exported value of the author and committer date, messing up my entire commit history!

### What about the `--date` switch?

Good question, I initially did my back to the past commit using that switch, but upon pushing it to GitLab I realized that the date shown was not in the past, but rather at the time I made the `git commit` command. Apparently GitLab (not sure about GitHub, haven't tried) uses the commit date and not the author date. Whereas the `--date` switch only allows you to specify the author date (meaning only `GIT_AUTHOR_DATE` is modified, not `GIT_COMMITTER_DATE`). Bummer.

Bonus tip: If you're just going to change the timestamps of the *previous* commit, go ahead and use the `--amend` flag:

	$ git commit --amend --date="YYYY-MM-DD HH:MM:SS"

Big credits to [this post](http://alexpeattie.com/blog/working-with-dates-in-git/) by Alex Peattie on highlighting the differences on dates, check it out, the post goes way more in-depth on working with git dates, as well as approximate dates and even a script to automate some processes! (Wonder if there's one for real life romantic dates too..) 


### Wait, what about existing repo's with history?


Well, assuming you have a commit history like so (meaning it isn't a fresh new repo) and you want to change the initial commit:

````
5ed237af	Added test cases (HEAD)
234cd89e	Implementation of feature X 		
144ab94e	Initial Commit 
````
What you want to do is first do a rebase with whichever commit you want, an interactive one is usually suggested, from what I've found online. And then export those `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE` values like I highlighted above, commit, *close the terminal* and then continue your rebase in another one to erase the exported value. (Or you could continue exporting other values to make it go back in time)

 	`$ git rebase -i HEAD~2 `

 Change 'pick' to 'edit' for the commit you want, then save. (use the no edit flag if you don't need to change to message)

 	`$ git commit --all --amend --no-edit`

 Close your terminal or reset the exported values (anyone know how to do this painlessly please comment!), then finally do (in a new terminal):

 	`$ git rebase --continue`

I initially tried this route but had issues (I had an empty commit before this, just a placeholder file and git didn't display that somehow, it was the commit I wanted to change the date for), and forgot to close my terminal so I ended up with multiple commits at the same time. Since I was just starting out it was just easier for me to delete my git and start over.

Read more on Stack Overflow on [how to modify a specific commit](http://stackoverflow.com/questions/1186535/how-to-modify-a-specified-commit-in-git) and [making a commit in the past](http://stackoverflow.com/questions/3895453/how-do-i-make-a-git-commit-in-the-past).