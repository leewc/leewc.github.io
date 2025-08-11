---             
title: Self Hosted Cloudflare Tunnels or Tailscale Alternative - Pangolin
excerpt: Quick blog post covering how to use Pangolin on a VPS for tunneling        
tags: [selfhosted, tunnels]        
date: 2025-08-10        
---             

This is a quick blog post detailing how to use Pangolin. 

There's a lot of other resources around how it works, why use it, but a use-case based rundown doesn't seem to exist, or at least I ran into many issues trying to understand it.

Hopefully, this won't be a waste of your time, I'll try and keep things light so it can be skimmed through!

If you're more of a watch-someone-do-it-to-understand kind of learner, this video helped me in seeing how Pangolin can be used: https://www.youtube.com/watch?app=desktop&v=I3fhhwptHzc (embedded at the end of this blog post)


## TL;DR 

Pangolin let's you tunnel applications/networks or ports typically not exposed to the public web. Pangolin does this using `Traefik` as a reverse proxy (and load balancer) and exposes dynamic configuration that defines the routes/resources being exposed. After which, `newt`, a user-space Wireguard client (i.e do not need `sudo`) is used to expose ports/resources typically not reachable by the public web.

Pangolin leverages `gerbil`, a Wireguard interface management server for tunneling and handling the Wireguard specific setup. 

A non-self hosted solution would be Tailscale or CloudFlare Tunnels (fka `cloudflared`).

*Note: Names of these tools are all `fossorial` animals (ie animals that burrow) because that is kind of what these tools do, dig holes on the Internet and do tunneling! The company's github ID makes that reference as `fosrl`.

Steps:
 1. Get VPS
 2. Get domain name for SSL
 3. Set up Pangolin
 4. Run `newt` on your internal network (can be docker)
 5. Expose services in Pangolin
 6. Add Auth

## Why 

Why not just use Cloudflare Tunnels? 
 - Yes you can, but it's not self hosted and there's terms and conditions that limit it's use. For example, you're not supposed to host Video via CloudFlare tunnels. So you can't expose your media server!
 - I also ran into issues when trying to tunnel from my VPS to Cloudflare, I lost access to it. Probably a ~~skill issue~~ due to IP tables.

Why not just use Tailscale Funnel?
 - This works! I went with Pangolin mainly because it's currently fully self-hosted. And while there is [Headscale](https://headscale.net/stable/) (open source alternative to Tailscale), which is officially supported at time of writing (I actually didn't know that!), Pangolin fits my stack a bit better because I had some prior experience with Traefik. The official Headscale deployment is also not containerized, there is a community supported method, though.

Why not just use a self-hosted Wireguard server?
 - Sure, I actually do that now. I have a WG server I VPN back into. Works great, but I can't deny it would be nice to expose web services safely (with authentication). 

## What is it for

The main reason I'm trying out these tunneling services is to see if I can 'safely' expose my homelab without opening up ports to each service individually. For example, (tinfoil hat on) my attack surface is larger if I expose Home Assistant to the internet. I know many do without issues, but I can't shake that I'm just one application vulnerability away from having all my homelab pwned. 

I'm also evaluating if I can use these mesh-based tunneling networks to punch through double-nat easily. It would be nice to drop some Raspberry Pi's or mini PCs in my relatives/friends home network and tunnel traffic between each site! 

Finally, I think it be good opportunity to test out tunneling for Dev work. 

The magic around tunneling is that instead of this, which relies on your Internet Service Provider providing you a public IP you can access:

```
[Internet] --> [ISP] -> [Firewall] --> [Home Network]
```

You can do something like this:

```
[Internet] ---> [Your Public Server ] <-|--> [Firewall] --> [Home Network]
```

But Pangolin also comes with OIDC support (bring your own Authentication) as well as protection of web resources via Password/Pin.


## How it works

I was going to cover this, but I realized I'd just be regurgitating their documentation. Read it here: https://docs.digpangolin.com/about/how-pangolin-works

You run `Pangolin` on your public instance, then `newt` on your machine that is not publically exposed. This can be via CLI, Docker, etc. Pangolin will then allow you to define resources for your to expose.

They also offer comparision with VPN and other solutions. Note you can also do site-to-site as well, or use Pangolin to enable VPN access.

## Before the Install

- You would need a domain name. This will allow you to enable HTTPS via Let's Encrypt. I use CloudFlare to manage my domain.
- You would also need a machine exposed to the internet. This could be AWS, Google Cloud, Oracle (they have a nice free tier), or Hetzer, et al.

Note if you don't self-host and just use Pangolin's hosted offering, none of these apply. Their free-tier currently allows 25GB of bandwidth, 3 users, 1 site and 1 domain. https://digpangolin.com/pricing

## Install Pangolin

Just follow their official docs [here](https://docs.digpangolin.com/self-host/quick-install), or [manual](/self-host/manual/docker-compose). I wasted some time going the manual route (wanted to use an existing traefik install and simulate Pangolin/Gerbil as individual HTTP endpoints), before deciding to bite the bullet and try their convenience installer to see if this was the right fit for me. (Docker compose attached at the end)

```
curl -fsSL https://digpangolin.com/get-installer.sh | bash
sudo ./installer
```

The installer generates a nice `docker-compose.yaml` that has the required containers (Gerbil, Pangolin, Traefik) to start up your own self hosted Pangolin. If install fails at any time, you can delete the compose file as well as the `config/` folder that is generated to start fresh!

Caveats:
 - Open the UDP and TCP ports they mentioned. I tested this with Oracle, so I had to go mess around with their Cloud dashboard to find the right place to add an ingress rule. I also had to change firewall settings on the host to allow traffic to hit Pangolin. 
 - Modify your Domain Name Registrar hosting your domain to point A records to your IP. You can find your IP with `curl ip.me`. 
 - Install can succeed but startup can fail if Traefik is not able to secure a HTTPS certificate from LetsEncrypt using the information you provided. You can debug this with `docker compose logs -f traefik`.
   - In my case, for some reason I wasn't able to get the HTTPS challenge to work. I wasted some time on this before deciding to do a DNS challenge instead as I know that works (and editing CloudFlare to point A records)
 
**Oracle Specific Steps**

Unintuitively, firewall rules are in your Instances page > Select instance > Networking > Select Subnet > Security > Default Security List > Security Rules > Ingress Rules . 
 - That's a lot of clicks. But AWS is no better. Utilize the search bar to search for 'Security List' or 'Security Rules' to avoid a few clicks. 
 - Do this for `UDP: 51820 and 21820` as well as `TCP: 80 and 443`.
 - Sample configuration
    ```
    Source: 0.0.0.0/0
    IP Protocol: UDP
    Source Port Range: All
    Destination Port Range: 51820
    Allows: UDP traffic for ports: 51820
    Description pangolin
    ```

Then run these on the host:

```
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p udp --dport 51820 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p udp --dport 21820 -j ACCEPT
sudo netfilter-persistent save   
```

## Post install

Go and follow the steps to set up an admin. 

You can also 'Add site' and go through Pangolin's onboarding wizard, it's fairly intuitive. Pangolin will ask you if you want to do tunneling, if you do, will give you options to deploy the `newt` binary.

On your home network's machine, 

```
wget -O newt "https://github.com/fosrl/newt/releases/download/1.4.0/newt_linux_arm64" && chmod +x ./newt
./newt --id 7qtmwy0huXXXXXXX --secret j5fxec0j0y8gh6y6nXXXXXXXX --endpoint https://pangolin.sub.exmaple.com
```

Note: Can also be a docker container, or a docker compose configuration if you want it to expose your many docker containers!

## Fun

With newt installed on the home machine. You should see the 'Site' you set up come 'online'.

Now go to Resources and expose resources! Make sure under Domain in 'Configure how your resource will be accessed over HTTPS', you click the domain that is available after you type. The current UX iteration made me think 'Create Resource' had an error and I couldn't proceed.

Also, after resource is created, what was not intuitive for me here is to configure the resources to be exposed from the perspective of the `newt` client. Under 'proxy', you would have ip/hostname as if you are on your home network, and port as well.

For example. If you installed on your homelab which also has a fileserver on `localhost:8080`, you would setup the resource to point to hostname `localhost`, and port `8080`. If you had a Docker deployment and Docker containers on the same network could communicate with each other by their name (eg `photoprism`), you would just have `photoprism` in the IP/hostname, along with the port it is at.

Now you can configure authentication like Password and PIN.

## End 

I'm going to see with this setup, if I prefer this over manually configuring Traefik rules. I can even run Pangolin on my other VPS and avoid exposing services via Wildcard DNS directly. Performance will be something to consider as the userspace client is less performant than the kernel WG client. Newt does have a flag to use the kernel WG implementation though.

The cool thing is also that this allows me to manage my Traefik setup as well.

Also, I just realized after trawling through documentation this is a YC25 company. Hope they don't change their ethos from allowing self-hosting. This was overall intuitive and I do like Pangolin UI and Tailscales UI.

## References

As promised, this video helped me in understanding how Pangolin works end to end. I don't know the author but found his video useful when trying to debug my setup!
- Specifically, at this timestamp: https://youtu.be/I3fhhwptHzc?t=948 he shows how to use it.

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/I3fhhwptHzc?si=GPRKAwJAkKL31Y-U" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

IF you are not interested in running their installer, here's my `docker-compose.yaml` modified with DNS challenge, so you understand the stack. You'll need to setup configuration, though: /self-host/manual/docker-compose#configuration-files

```
name: pangolin

# Avoid hardcoding secrets in docker-compose or in traefik itself
secrets:
  cf_dns_api_token:
    file: '~/.secrets/cf_dns_api_token'

services:
  pangolin:
    image: docker.io/fosrl/pangolin:1.8.0
    container_name: pangolin
    restart: unless-stopped
    volumes:
      - ./config:/app/config
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/api/v1/"]
      interval: "10s"
      timeout: "10s"
      retries: 15

  gerbil:
    image: docker.io/fosrl/gerbil:1.1.0
    container_name: gerbil
    restart: unless-stopped
    depends_on:
      pangolin:
        condition: service_healthy
    command:
      - --reachableAt=http://gerbil:3003
      - --generateAndSaveKeyTo=/var/config/key
      - --remoteConfig=http://pangolin:3001/api/v1/gerbil/get-config
      - --reportBandwidthTo=http://pangolin:3001/api/v1/gerbil/receive-bandwidth
    volumes:
      - ./config/:/var/config
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    ports:
      - 51820:51820/udp
      - 21820:21820/udp
      - 443:443 # Port for traefik because of the network_mode
      - 80:80 # Port for traefik because of the network_mode

  traefik:
    image: docker.io/traefik:v3.4.1
    container_name: traefik
    restart: unless-stopped
    secrets:
      - cf_dns_api_token
    network_mode: service:gerbil # Ports appear on the gerbil service
    environment:
      - CF_DNS_API_TOKEN_FILE=/run/secrets/cf_dns_api_token
    depends_on:
      pangolin:
        condition: service_healthy
    command:
      - --configFile=/etc/traefik/traefik_config.yml
    labels:
      - traefik.http.routers.api.tls.domains[0].main=subdomain.example.com
      - traefik.http.routers.api.tls.domains[0].sans=*.subdomain.example.com
    volumes:
      - ./config/traefik:/etc/traefik:ro # Volume to store the Traefik configuration
      - ./config/letsencrypt:/letsencrypt # Volume to store the Let's Encrypt certificates
      - ./config/traefik/logs:/var/log/traefik # Volume to store Traefik logs

networks:
  default:
    driver: bridge
    name: pangolin
    enable_ipv6: true
```