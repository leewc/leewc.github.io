---             
title: Set up Fail2Ban on host with ntfy.sh
excerpt: I tried it with Docker, and fail2ban "failed-2-ban" anything.. 
tags: [linux, ssh] 
date: 2026-03-29        
---             

I came to the realization that some things should not be dockerized. Especially depending on the use-case. 

I want to block IP addresses trying to connect to my SSH process on port 22. `sshd` runs on the host. And while I am very much a fan of Docker and running everything via docker, this endeavor resulted in hours wasted. 

It also taught me to actually verify IP addresses were being banned. I should have probably just moved SSH out of the default port, but if you wanted to stick to port 22, you definitely need some kind of banning as there are many attempts to brute force in the wild west that is the Internet.

So this is how I set it up on the host itself, took me 15 minutes, and it went so much smoother. 

If you do get it working do share, I know it's possible and it must be a skill issue... but I poured too much time into this!

## Uncontainerized - the good ol' way

```
cat /etc/debian_version

sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Make edits to `/etc/fail2ban/jail.local`, this is what I have when you scroll to the `sshd` section

```
[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
mode   = aggressive
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
enabled = true
bantime.maxtime = 5w
bantime.increment = true
bantime = 1h
maxretry = 3
# Prevents banning LAN subnets
ignoreip    = 127.0.0.1/8 ::1
              10.0.0.0/8
              172.16.0.0/12
              192.168.0.0/16
action = %(action_mw)s
         ntfy

```

*Bonus* - I also added an action to publish to ntfy.sh when an IP is banned!

Run `sudo nano /etc/fail2ban/action.d/ntfy.conf`
```
[Definition]
actionban = curl -d "Banned <ip> on <name>! [Fail2Ban]" https://ntfy.sh/<your-own-topic>
# No action to unban
actionunban =

[Init]
```

*Bonus bonus* - With the help of AI, I even found ipinfo.io (I was going to use MaxMind's database with auth, but this worked well for my low volume banning)

```
[Definition]
actionban = curl -d "Banned <ip> from $(curl -s https://ipinfo.io/<ip>/country) on <name>! [Fail2Ban]" https://ntfy.sh/<your-own-topic>
```

FYI:
- `curl -s https://ipinfo.io/<ip>` has a lot more info too.

And... with emoji flags just because it looks better.

```
[Definition]
actionban = curl -d "[Fail2Ban][<name>] Banned <ip> from $(curl -s https://ipinfo.io/<ip>/country | python3 -c "import sys; code=sys.stdin.read().strip(); print(''.join(chr(127397+ord(c)) for c in code))") !" https://ntfy.sh/<your-own-topic>

```

This part I did not come up with, as I was curious of the magic number `127397`. 

Breakdown:
- ord(c) - gets ASCII value of letter (e.g., 'N' = 78, 'L' = 76)
- 127397 + ord(c) - adds offset to get regional indicator symbol
  - 'N' (78) + 127397 = 127475 (🇳)
  - 'L' (76) + 127397 = 127473 (🇱)
- chr(...) - converts number back to character
- ''.join(...) - combines both characters into flag emoji

Example with "NL":
- N → ord('N') = 78 → 78 + 127397 = 127475 → chr(127475) = 🇳
- L → ord('L') = 76 → 76 + 127397 = 127473 → chr(127473) = 🇱
- Combined: 🇳🇱

Flag emojis are made by pairing two "Regional Indicator Symbol" characters (U+1F1E6 to U+1F1FF). The offset 127397 maps A-Z (65-90) to these Unicode positions.

## Commands that might be useful for you when debugging

Check if another firewall is running

```
sudo ufw status
```

Check which iptables backend you're running

```
sudo iptables -V
```

Check the `nftable` ruleset

```
sudo nft list ruleset
```
- (sudo is important here otherwise you'll get partial output)


Restart/Start Fail2ban 

```
sudo systemctl restart fail2ban
```

Check if the jail is running

```
sudo fail2ban-client status sshd
```

Verify your IPTables are being modified, and view the specific chain

```
sudo iptables -L
sudo iptables -L f2b-sshd # add  -nL if you want to skip DNS resolution
```

If it fails, time to debug either with:

```
sudo cat /var/log/fail2ban.log
```

or 

```
sudo journalctl -xeu fail2ban.service
```

You can print configuration with

```
fail2ban-client --dp
```

And go about your merry way! 
## Docker (fail)

If you're actually interested as to why Docker failed for me, it's actually because Docker containers run on `iptables` and Docker manages its own iptables chains (DOCKER, DOCKER-USER, etc.) fail2ban's rules get inserted into chains that don't affect Docker's forwarded traffic., As such even if we align with what is on host - as `nftables` or `firewalld`, it won't work unless you try and have fail2ban manipulate the host directly. Even then, the rules in `iptables` are not compatible with `nftables` unless you install another package to handle legacy rulesets. So when the `fail2ban` Docker container tries to modify the IP tables, it only modifies the Docker chain. They do not actually take effect on the host level. In my case, the host system was Debian, and my distribution had `firewalld` installed (I believe the stock default was iptables). With three different ways of blocking IPs which are not cross compatible, Docker just adds unnecessary complexity. Add to the silent failures: it might look like fail2ban blocked an IP address, but in actual fact the block wasn't actually taking effect. 

![It's Always Sunny In Philadelphia S04E10](https://i.imgur.com/uWYuDFu.jpeg)

But if you're better than I am and really want to go down this path, I will attach the following for your reference, be sure to check which firewall you're using on the host! (`sudo ufw status` is a good starter):

Check if your jails are running

```
docker compose exec fail2ban fail2ban-client status --all
```

If you want to you can also directly drop into a shell with `docker exec -it fail2ban /bin/sh`

Check in docker if any fail issues

```
docker compose exec fail2ban fail2ban-client --dp
```

Drop into a shell on the container

```
docker exec -it fail2ban /bin/sh
```

This will print the configurations of fail2ban in docker

```
['set', 'logtarget', '/config/log/fail2ban/fail2ban.log']
```

This should show you the error (if any)

```
banaction = nftables[type=multiport]
```


### Additional References
- https://www.serverspan.com/en/blog/fixing-fail2ban-with-dockerized-vaultwarden-behind-caddy-why-bans-dont-block-and-how-to-solve-it 
