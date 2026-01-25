---             
title: Setting up simple Obsidian Sync Backup on mac OS
excerpt: Or any directory really..
tags: [obsidian]        
date: 2026-01-24        
---             

## TL;DR

Use `rsync` and a `launchdaemon` configuration to keep a copy of notes remotely, leverage a cloud backup service like Google Drive/OneDrive/Dropbox as well.

## Intro

I had a bunch of notes on my Mac that I moved away from Evernote after it's been nerfed to only allow one device to access and sync notes. With this I decided to move to a more durable setup. 

After moving to Obsidian as my current(tm) note taking app of choice (previously Evernote, previously Bear). I miss the sync aspect. There's Obsidian Sync but that isn't necessarily allowed for my work laptop. I also didn't want to pay yet another subscription fee.

I will say that it's not the *easiest* way for everyone, but I think this setup of using:
 1. A cloud service to back up notes
 2. A remote server/home computer to also keep a copy of notes
 3. Obsidian/Bear or any note taking app that keeps notes as portable files (eg Markdown).

Is a fairly good setup. If you're thinking of following this guide, just remember, this is secondary to the process of note-taking. The best note-taking app is one that works *for you*! You do you!

## Setup

A quick and dirty solution is Unison or Rsync. To keep things simple and use existing preinstalled tools on the Mac, I went with `rsync`.

Command is easy:

```
rsync -razu /Users/myUserName/Library/Drive-Documents/obsidian/notes/ xxx@example.com:/home/myUserName/media-homelab/docs/documents/nyUserName/notes
```

What the flags mean:

```
-r : Go recursive
-a : Archive (preserve read time stamps)
-z : Use text compression to reduce network overhead
-u : Update (skip files newer on receiver)
```

A great resource for me to understand rysnc is this blog post by DigitalOcean: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories#using-rsync-to-sync-with-a-remote-system

## Not Recommended: Use crontab

This didn't work on my Mac, so I'd skip it. However, I'm keeping it here if you're on another OS! I'd skip this section and go read the [Launch Daemon](#launch-daemon-recommended) steps instead.

### Add crontab

Running `crontab -e` will pop open an editor for cron. 

To Execute Script Every Hour

```
0 */1 * * * myUserName rsync -razu /Users/myUserName/Library/Drive-Documents/obsidian/notes/ xxx@example.com:/home/xxx/media-homelab/docs/documents/xxx/notes
```

To list all cron jobs, `crontab -l`. 

If you need help configuring your cron schedules (who doesn't): https://crontab.guru/ is great!

### Permissions

`cron` will need permissions to access the disk, I had to go through the steps of allow listing `cron` under the Mac's "Privacy and Security" settings. Credit to this blog post that helped me figure that out: https://michaelriedl.com/2022/01/02/macos-cron-rsync.html

^I think `rsync` would also need this permission to access the disk as rsync is the program triggering the disk access. 

### Results 

I found out cron didn't work (waited till on the hour but my computer went to sleep). That's when I realized `cron` doesn't run if computer is asleep. It would just skip the run.

Rather, it turns out `launchdaemon` is the preferred method for Mac 

> **Note:** Although it is still supported, `cron` is not a recommended solution. It has been deprecated in favor of `launchd`.
> https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/ScheduledJobs.html. 


## Launch Daemon (Recommended)

1. Here's a sample plist which you put into `~/Library/LaunchAgents`:
```
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>Label</key>
	    <string>com.myUserName.notessync</string>
	
	    <key>ProgramArguments</key>
	    <array>
	        <string>/usr/bin/rsync</string>
	        <string>-razu</string>
	        <string>/Users/myUserName/Library/Drive-Documents/obsidian/notes/</string>
	        <string>xxx@example.com:/home/xxx/media-homelab/docs/documents/xxx/notes</string>
	    </array>
	
	    <key>StartInterval</key>
	    <integer>3600</integer>
	
	    <key>RunAtLoad</key>
	    <true/>
	
	    <key>UserName</key>
	    <string>wenlee</string>
	
	    <key>StandardOutPath</key>
	    <string>/tmp/com.myUserName.rsync.out.log</string>
	
	    <key>StandardErrorPath</key>
	    <string>/tmp/com.myUserName.rsync.err.log</string>
	</dict>
	</plist>
```  

2. `launchctl load ~/Library/LaunchAgents/com.myUserName.rsync.plist`

3. Yes, you'll also have to grant `rsync` perms as a consequence of new privacy protections.

4. If you happen to have copy-pasta errors: `plutil ~/Library/LaunchAgents/com.myUserName.rsync.plist` will print `com.myUserName.rsync.plistc.plist: OK` to validate your set up is 'valid'.

5. You might need to `unload` then `load` as well: 

```
launchctl unload ~/Library/LaunchAgents/com.myUserName.rsync.plist
launchctl load ~/Library/LaunchAgents/com.myUserName.rsync.plist
launchctl kickstart gui/$(id -u)/com.myUserName.rsync.plist
```

## Cloud Sync

It's probably a good idea to also keep a backup on the Cloud. To do so just install your favourite Cloud syncing app and ensure that folder is backed up. The Obsidian Vault is essentially just a folder you can backup!

## How's it going

The setup has been working well. However, one caveat I noticed was that depending on where your vault is stored, if it's a folder that is cloud folder, certain services (such as Amazon WorkDocs, or [OneDrive](https://support.microsoft.com/en-us/office/save-disk-space-with-onedrive-files-on-demand-for-windows-0e6860d3-d9f3-4971-b321-7092438fb38e)) will try and move your files to the cloud and delete the local copy. This is undesirable as Obsidian doesn't work well with these files that have been moved to the cloud and are 'online-only', the notes simply disappear. One solution to this is to either move the files to outside of the cloud folder and `rsync` to that in addition to the external backup you have. Alternatively, OneDrive has the option to mark them as 'always available' by selecting 'always keep on this device'. 

## What's next

This is still kind of a one-way sync, but I think I'll graduate to Unison if I need 2 way sync in the future and update this blog post.

## Bonus: Static Site of your notes

I also wanted to be able to view my notes on the remote server I `rsycned` via a web browser. My quick low-effort solution was using MkDocs in addition to [FileBrowser](https://filebrowser.org/index.html), which is a very lightweight web UI for viewing and uploading files and is feature complete.

MkDocs can be ran in Docker + Traefik using [this `polinux/mkdocs` image](https://github.com/pozgo/docker-mkdocs).

### Mkdocs

`docker-compose.yaml`
```
 notes:
    image: polinux/mkdocs:arm64v8-1.5.2
    container_name: notes
    environment:
      - PUID=1000
      - PGID=1000
      - TZ='America/Los_Angeles'
      - FAST_MODE=true
      - UPDATE_INTERVAL=60
      - AUTO_UPDATE='true'
    volumes:
      - path-to-notes-dir/:/mkdocs:ro
    restart: unless-stopped
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.notes.rule=Host(`notes.example.com`)'
      - 'traefik.http.services.notes.loadBalancer.server.port=8000'
      - 'com.centurylinklabs.watchtower.enable=true'
```

`mkDocs.yml`

```
site_name: Muh Notes
docs_dir: notes

theme:
    name: 'readthedocs' #'material'
    palette:

    # Light mode
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: pink
      accent: indigo
      toggle:
        icon: material/toggle-switch-off-outline
        name: Switch to dark mode

    # Dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: pink
      accent: blue
      toggle:
        icon: material/toggle-switch
        name: Switch to light mode

# Extensions
markdown_extensions:
  - footnotes
  - def_list
fence_code_format
  - toc:
      permalink: true

plugins:
  - search

extra_javascript:
  - javascripts/mathjax.js
  - https://polyfill.io/v3/polyfill.min.js?features=es6
  - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
  - https://unpkg.com/mermaid/dist/mermaid.min.js %       
```

MkDocs works OK but the formatting is a bit off here, as I do not want to introduce custom frontmatter for my notes.

### Quartz

I found [Dockerized Quartz](https://github.com/shommey/dockerized-quartz) which fit my setup perfectly (except it didn't have ARM builds, ~~I will have to submit a PR for it~~ looks like someone has a PR: https://github.com/shommey/dockerized-quartz/pull/4).

The site generated is much nicer for sure!

```
 notes:
      # image: shommey/dockerized-quartz
      build:
        context: ./dockerized-quartz
        dockerfile: Dockerfile
      container_name: notes
      environment:
        - BUILD_UPDATE_DELAY=120
        # Optional: Auto rebuild Quartz after change in Obsidian Vault 
        - AUTO_REBUILD=true
      networks:
        - web
      volumes:
      # Mount your Obsidian vault for Quartz to read and build the site from
      # If not set it will mount docs
        - /path-to-my/notes:/vault:ro
      #
      # Optional: Mount existing Quartz repo
      # - /path/on/host:/usr/src/app/quartz
      #
      # Optional: Persist nginx logs if needed
      # - /path/to/nginx/logs:/var/log/nginx
      #
      # Optional: Mount nginx conf
      # - /path/on/host:/etc/nginx
      restart: unless-stopped
      labels:
          - 'traefik.enable=true'
          - 'traefik.http.routers.notes.rule=Host(`notes.example.com`)'
          - 'traefik.http.routers.notes.service=notes'
          - 'traefik.http.services.notes.loadBalancer.server.port=80'
          - 'com.centurylinklabs.watchtower.enable=true'
```

You'll need an `index.md` at the top level though.