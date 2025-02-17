---             
title: Docker Compose Caveats
excerpt:        
modified:       
tags: []        
date: 2025-02-16        
---             

These are some gotchas I ran into when I've been messing with Docker compose files for my homelab. I'd like to document them to make up for my lost time. Maybe you'll find it useful as you stumble on it when searching on Google or your favorite LLM that ingested this data to present it to you. 

I'll do my best to edit this post or link to other posts if I find more caveats worth sharing.

## Volumes are not automatically deleted if path not found

**TL;DR**: Volume creation contains side effects, when you mess up during development, use `docker volume rm <volume_name>` to get back up and running.

Suppose you have a minimal compose file like so, which uses the excellent minimal web [filebrowser](https://github.com/filebrowser/filebrowser) to mount a directory, here being `media`:

```yaml
services:
  filebrowser:
    image: filebrowser/filebrowser:s6
    container_name: filebrowser
    restart: unless-stopped
    volumes:
      - media:/srv/data/media
      - ./filebrowser:/database/
      - ./filebrowser:/config/

volumes:
  # Specify an absolute path mapping
  media:
    driver: local
    driver_opts: 
      device: /path/to/media
      o: bind
      type: local
```

When you go ahead and `docker compose up`, it will try and create the Docker volume. However, if you had a typo in the `device` section, i.e instead of `/path/to/media` you had `/path/to/mdiae`. The compose is going to fail.

```
 docker compose up       
[+] Running 1/1
 ✔ Container filebrowser  Created                                                

Attaching to filebrowser
Gracefully stopping... (press Ctrl+C again to force)

Error response from daemon: error while mounting volume '/var/lib/docker/volumes/XXXX/_data': failed to mount local volume: mount /path/to/mdiae:/var/lib/docker/volumes/XXXX/_data, flags: 0x1000: no such file or directory

```

You would think, ah, I as a human, made that mistake. Rather. I need to fix that typo. You fix it. Then you go ahead and `docker compose up` again. 

*The expectation* is that since it failed, it should recreate that volume and try again. This doesn't happen.

Rather, it'll keep on returning this:

```
Error response from daemon: error while mounting volume '/var/lib/docker/volumes/XXXX/_data': failed to mount local volume: mount /path/to/mdiae:/var/lib/docker/volumes/XXXX/_data, flags: 0x1000: no such file or directory
```

**The solution?** `docker volume rm XXXX` 

Where `XXXX` is pretty much the 'parent' folder + name of the volume mount. i.e If you started up this compose in `tmp`, your volume name is `tmp_media`.

I got stuck because I was thinking for some reason my Compose file wasn't being updated or I had to restart the Docker daemon. Or that something is wrong with local volume moint points. Heck, I even deleted the volume configuration and it wasn't able to start up.

However, after trying to reproduce this as I am writing this post, on a more recent Docker version 27.5.1, Compose was even smart enough to tell me that 'Volume' exists but doesn't match, and kindly asks if I want to recreate it.

```
> ? Volume "tmp_media" exists but doesn't match configuration in compose file. Recreate (data will be lost)? Yes
```

So maybe I didn't need to write this caveat out, but I hope it helps someone.