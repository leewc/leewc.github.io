---
layout: post
title: How to Merge Multiple Git Repositories Into One Repo
excerpt: Tutorial on combining smaller repos into a large master repo
modified:
categories: articles
tags: [tutorial, git]
comments: true
share: true
image:
  feature:
date: 2016-04-13T01:25:28+00:00
---

# Why 

Recently I decided to open source most of the projects I've worked on in Fall [^2]. 
For the classes that I've kept a private git repo on [^1], I had about 4 repos, each with their own master branch, and another 1 group repo. 

I could have easily pushed it all to GitHub but I would have separate individual repos, and I felt it would clutter up my repositories, since it's unlikely
I'll work on those repositories again, and people who actually will look at it are most likely other students that take the class in the future.

Alternatively, copy pasting all the latest files would suffice, but I'd lose commit info, history, which doesn't seem right to me.

Merging multiple project repos into one is however counterintuitive to the principle that for each distinct project, [have a separate repo](http://programmers.stackexchange.com/questions/161293/choosing-between-single-or-multiple-projects-in-a-git-repository),
but given this is all considered *academia*, I wanted to group it all together.

It took me more time than I'd care to admit, but I decided to share this here in case anyone else is looking to consolidate their repositories.

# Prerequisites and Goals

Prerequisites for me currently are:

- 4 repos, all separate and isolated. 
- Each with a `master` branch

Goals:

- Merge into one large repository
- Keep track of all commits
- Keep history intact
- Separate branches for each repo merged

# How to do it:

## Step 1.

Initialize an empty repository in an empty directory with `git init`. This will be our 'master' repository.

## Step 2.

Add a readme and perform an initial commit.

~~~ bash
    $ touch README.md
    $ git add README.md
    $ git commit -am 'Inital Commit'
~~~

## Step 3.

Create an empty branch named `clean`. This will be the base branch we'll merge other repositories into. This is necessary as the `master` branch will no longer be empty later.

~~~bash
    $ git branch clean
~~~

## Step 4.

If we list the branches in our repo with `git branch --all`. This is the output

~~~bash
    clean
    * master
~~~

## Step 5.

Now checkout the clean branch with `git checkout clean`. We're on the `clean` branch.

## Step 6.

For this tutorial I'll use `old_A` as the old repo. We'll add a remote branch to `old_A` (named `remote_A`, a remote repo can be a local dir with a `.git` inside it, or a web address.
  
~~~bash  
    $ git remote add remote_A https://github.com/username/proj_A.git
~~~

*alternatively, `git remote add remote_A ~/folder/to/project_A`

## Step 7.

Fetch all the branches!

~~~bash
    $ git fetch --all
~~~

Here's the sample output from me pulling in my [legacy Github Pages repo](https://github.com/leewc/legacy).

~~~bash
    Fetching remote_A
    warning: no common commits
    remote: Counting objects: 822, done.
    remote: Total 822 (delta 0), reused 1 (delta 0), pack-reused 821
    Receiving objects: 100% (822/822), 4.95 MiB | 1.94 MiB/s, done.
    Resolving deltas: 100% (475/475), done.
    From https://github.com/leewc/legacy
     * [new branch]      gh-pages   -> remote_A/gh-pages
     * [new branch]      master     -> remote_A/master
~~~

## Step 8.

Time to create & checkout a branch we want to pull our old repository into. I'll use `project_A` as the 'new' branch we want to hold the old repo.
(Also, note that I'm using `remote_A/master` as the branch I want pulled. You'll need multiple branches for multiple branches (*lol.. duh?*) ).

~~~bash
    $ git branch project_A remote_A/master
    Branch project_A set up to track remote branch master from remote_A.
    $ git checkout project_A
    Switched to branch 'project_A'
    Your branch is up-to-date with 'remote_A/master'.
~~~

## Step 9.

If we do an `ls` now, you'll see your files from the old project A in `remote_A`. If you didn't you're not on the right branch, or you messed up. 
Also, if you ran `git branch --all` you'll get a `master` branch, `clean` branch, `project_A` branch and all remote branches showing up.

## Step 10.

Looks good, go back to the master branch, and merge in the `project_A` branch. We have a couple options here. If you do a regular `git merge`, all commits will
show up on master, which is great if you want GitHub to track and show more commits, but this gets out of hand when you merge other projects, as the commits are
ordered by time, and you get nonsensical chronology, unrelated commits intersecting. It's up to you, but let's do `git merge --squash` instead so we have one
squashed commit per project on `master`.

~~~bash
    $ git merge --squash project_A master
    Auto-merging README.md
    Squash commit -- not updating HEAD
    Automatic merge went well; stopped before committing as requested
~~~

## Step 11.

Make a commit showing what you did. (this won't happen if you didn't do `squash`)

~~~bash
    $ git commit -am 'Squashed proj_A'
    [master 25af1be] Squashed proj_A
     111 files changed, 9458 insertions(+)
~~~

## Step 12.

Time to delete the remote branch since we don't need to keep a reference to it.

~~~bash
    $ git remote remove remote_A 
    $ git branch --all
        clean
      * master
        project_A
~~~

## Step 13.

You can now delete your old remote branch, we don't need it anymore.

## Step 14.

Add a new remote for the master repo, and then push the branch up to your remote! (E.g that GitHub url for your new repo you created, make sure you don't initialize the remote repo with a README)

~~~bash
    $ git remote add origin https://github.com/yourusername/master-repo-name.git 
    $ git branch --all
    $ git push -u origin master
    $ git push -u origin project_A
~~~

## Step 15.

Repeat [Step 5](#step-5) to [Step 13](#step-13) for other repositories, pushing the repository to origin after with `git push -u origin name_of_branch`

## Step 16.

You should now have a nice 'master' repo. With commits on the master being squashed commits, and each branch holding it's own commit history.

![apollo-academia-screenshot](/images/articles/apollo-academia.png)

[^1]: the university I go to provides Enterprise GitHub!
[^2]: by recently I meant January, and *repo can be found [here](https://github.com/leewc/apollo-academia-umn)*.