---             
title: Uniqlo's Peace For All Easter Egg
excerpt: Nerd sniped by a t-shirt so you don't have to
tags: [ base64 ]        
image:          
    path: images/blog/akamai_peace_for_all_header.jpg
    thumbnail: images/blog/akamai_peace_for_all_header.jpg
date: 2025-12-29        
---             

Recently while exploring Uniqlo during the holiday season I stumbled on this shirt. It's part of a collab between Uniqlo and Akamai Technologies (large CDN complany) promoting the Peace for All series. 

![Uniqlo's peace for all series shirt in collaboration with Akamai](/images/blog/akamai_peace_for_all.jpg)

It immediately piqued by interest as clearly it was Base64 encoding of some kind of bash script. Also worth mentioning is the very clean and minimal front part of the shirt, which you can see [is a small heart](https://image.uniqlo.com/UQ/ST3/WesternCommon/imagesgoods/480814/sub/goods_480814_sub14_3x4.jpg)

Here's the easter egg which I hope you find just by searching for it online!

## The Noob OCR Attempt

I tried using Google's AI Lens to do some text extraction, and then pasted it for when I got back to my laptop. While it looked like it got *most* of it right. I needed it to be 100% correct. 

I tried cleaning up the whitespaces and pasted it into CyberChef to decode the bash script. I really do like CyberChef, I use an internally hosted version for work often, as I wrangle with different things like Base64, JWE tokens etc. 

Alas, it was not very accurate. it  looks like even Base64 armored shirts have lossy conversion from image-to-text.

[Here's an attempt](https://gchq.github.io/CyberChef/#recipe=Remove_whitespace(true,true,true,true,true,false)From_Base64('A-Za-z0-9%2B/%3D',true,false)&input=SXlFdlltbHVMMkpoYzJnS0NpTWdRMjl1WjNKaGQKCkhWc1lYUnBiMjV6SVNCWmIzVWdabTkxYm1RZ2RHaGxJR1ZoYzNSbGNpQjFaMmNoSU9LZHBPKzRqd29qSU9PQml1byBDZ2VPQnArT0JxMDBCaHVPQjEwMEJsdU9CaE9PQnZ1MEJtZSs4Z2VtYW9PMEJsZU9Dak9PQm4rT0N0ZU9EMSswRCBxZU9DcDBPQ3V1MENrdWltaStPQnAwT0JrZU9CdnVPQmwrT0JuKys4Z2VLZHAwKzRqd29LSXlCRVpXWnBibVVnZCBHaGxJSFIxZUhRZ2RHOGdZVzVwYldGQFpRcEBaWGhAUFNMaW1hVlFSVUZEUmVLWnBVWlBVdUtacFVGTVRPS1pwViBCRlFVTkY0cG1dUms5UzRwbV1RVXhNNHBtXVVFVkJRMFhpbWFWR1QxTGltYVZCVEV6aW1hVlFSVUZEUmVLWnBVWiBQVXVLWnBVRk1UT0tacFZCRlFVTkY0cG1dUms5UzRwbWxRVXhNNHBtbElnb0tJeUJIWlhRZ2RHVnliVzF1WVd3ZyBaR2x0Wlc1emFXOXVjd3BqYjJ4elBTUW9kSEIxZENCamIyeHpLUXBzYVc1bGN6QGtLSFJ3ZFhRZ2JHbHVaWE1wQyBnb2pJRU5oYkdOMWJHRkBaU0IwYUdVZ2JHVnVaM1JvSUc5bUlIUm9aU0IwWlhoQENuUmxlSFJmYkdWdVozUm9QUyBSN0kzUmxlSFI5Q2dvaklFaHBaR1VnZEdobElHTjFjbk52Y2dwMGNIVkBJR05wZG1dekNnb2pJRlJ5WVggZ1ExUlMgVEN0RElIUnZJSE5vYjNjZ2RHaGxJR04xY25OdmNpQmlaV1p2Y21VZ1pYaHBkR2x1WndwQGNtRndJQ0pAY0hW2EkgR051YjNKdG95QmxlRzEwSWlCVFNVZCBKVElRS0lNR1UyVk9JIFUyVk9JR1pZWlhGMSBJWlc1amVTQnpZMkZzYVc1bklHWmhZM1IgdmNncG1jbVZYUFRBVU1nbyBLSVkgQkogQkpibVpwYm1sMFpTQnNiMjl3SUdadmNpQmpiIGpiMjUwYVc1MWIzVnpJR0Z1YVcxaGQgR2x2YmdwbWIzSWcgS0NnZyBnZ2REMHdPeUE3SUhRclBURWdLU2s3SUdSdkNpQWdJQ0FqSUV2IEVWNGRISmhZM1FnYjI1MUlHTiBZWEpIWTNSMWNpQmhkIGhkQ0JoSUhScGJXVUtJQ0FHSUdOT1lYSTlJaVI3ZEdWNGREcCBDVWdkR1Y0ZEY5cyBaVzVuZCBHZzZNWDBpQ2lBZ0lDIGdJQ0FLSUNBZ0lDTWdRMkZzWTNWc1lYUjFJSFJvWlNCaGJtZHNaU0JwYmlCeVlXUnBZVzV6Q2lBIGdJQ0JoYm1kc1pUMGsgWzBrS0dWamFHOGdJaWdrZENrZ0tpQWtabmpsY1NJZ2ZDQml5eUF0YkNLS0NJQUdJQ0FKSUVOaGIgR04xYkdG2FpTQjBhIEIwYUdVZ2MybHVaU0J2WmlCMGFHVWdZVzVuYkdVS0lDQWdJSE5wYm1WZmRtRnNkV1U5SkNobFkyIGh2SUNKektDUmhibWQgbWRzWlNraUlId2dZbU1nTFd3cENnb2dJQ0FnSXlCRFlXeGpkV3hoZEdVZ2VDQndiM05wZEcxIHZiaUIxYzJsdVp5QkAgQkBhR1VnYzJsdVpTQjJZV3gxWlFvZ0lDQWdlREBrS0dWamFHOGdJaWdrWTI5c2N5QXZJRElwSUMgc2dLQ1JqYjJ4eklDOCBDOGdOQ2tnS2lBa2MybHVaVjkyWVd4MVpTSWdmQ0JpWXlBdGJDa0tJQ0FnSUhnOUpDaHdjbWx1IGRHWWdJSVVVTUdZSUlDIElDSWtlQ0lwQ2dvZ0lDQWdJeUJGYm5OMWNtVWdlQ0JwY3lCIHlCM2FYUm9hVzRnZEdWeWJ3bHVZIFd3Z1ltOTFibVJaQ0lBIDFBZ0lDQnBaaUFPS0NCNElEd2dNQ0FwIEtUc2dkR2hsYmlCIGlCNFBUQTdJR1pwQ2lBZ0lDQlBaaSBBb0tDQjRJRDQ5SUdOViBOdmJITWcgS1NLN0lIUk9aVzRnZURAa0tDaGpiMnh6SUMwZyBhZ01Ta3BveSBCbWEgUU9LSUNBR0lDTSBnUTJGc1kzVnNZWFJsSUdOIExJR052Ykc5eUlHZHlZV1JwWlc1MElHSjFkIFJQWlc1MElHSmxkSGRsWlc0Z01USWcgSGRsWlc0Z00gS0dONVlXNFBJR0ZVWkNBWU0gQ0FnSUdOdmIgZ0lDQmpiMnh2Y2w5eVlXNW5aVDBrS0NoamIyeHZjbDlsYm1RZ0xTQmpiMnh2Y2w5emRHRnlkQ2twQ2lBZ0lDQmpiIDJ4dmNqQGtLQ2hqYjJ4dmMxOXpkR0Z5ZENBcklDaGpiMnh2Y2w5eVlXNW5aU0FxSUhRZ3lCc2FXNWxjeWtnSlNCaiBiMnh2YzE5eVlXNW5aU2twQ2dvZ0lDQWdJeUJRY21sdWRDQjBhR1VnWTJoaGNtRmpkR1Z5SUhkcGRHZ2dNalUyTAoKV052Ykc5WUlITjFjSEJ2ZW5RS0lDQWdJR1ZqYUc4ZyBXNTFJQ0pjTURNeld6TTRPelU3Skh0amIyeHZjbml0bGlRCgpvZEhCMWRDQmpkIFhBZyBKSFFnIEpIZ3BJaVJqYUdGeVhEQXpNMXN3YlNJS0NJQUdJQ0FKSUV4cGJtVWdabVZJWkNCZWIKCnlCdGIzWjFJR1J2ZDI1M1lYSmtDaUFnSUNCMVkyaHZJQ0lpQ2dwa2IyNTFDZ289IA) of me taking the extracted base64 text and trying to decode it. It does look like it got some of it right! I see a nice comment: "Congratulations! You found the easter egg!"

Now if I was super fixated on this I would likely go and manually type it in myself or try snapping another photo and running it through a few more text extractors. 

However, there's already someone else that is more nerd than I am, shouout to [`k2-gc`](https://qiita.com/k2-gc) of qiita.com. Their [blog post](https://qiita.com/k2-gc/items/d3e69b59ab26fabb2a80) links the [shirt](https://www.uniqlo.com/jp/ja/products/E480814-000/00?colorDisplayCode=30&sizeDisplayCode=004) on the Uniqlo website and their endeavor of using OCR! 

Here's the Base64 encoded string if you'd like to follow along and copy paste:

```
IyEvYmluL2Jhc2gKCiMgQ29uZ3JhdHVsYXRpb25zISBZb3UgZm91bmQgdGhlIGVhc3RlciBlZ2chIOKdpO+4jwojIOOBiuOCgeOBp+OBqOOBhuOBlOOBluOBhOOBvuOBme+8gemaoOOBleOCjOOBn+OCteODl+ODqeOCpOOCuuOCkuimi+OBpOOBkeOBvuOBl+OBn++8geKdpO+4jwoKIyBEZWZpbmUgdGhlIHRleHQgdG8gYW5pbWF0ZQp0ZXh0PSLimaVQRUFDReKZpUZPUuKZpUFMTOKZpVBFQUNF4pmlRk9S4pmlQUxM4pmlUEVBQ0XimaVGT1LimaVBTEzimaVQRUFDReKZpUZPUuKZpUFMTOKZpVBFQUNF4pmlRk9S4pmlQUxM4pmlIgoKIyBHZXQgdGVybWluYWwgZGltZW5zaW9ucwpjb2xzPSQodHB1dCBjb2xzKQpsaW5lcz0kKHRwdXQgbGluZXMpCgojIENhbGN1bGF0ZSB0aGUgbGVuZ3RoIG9mIHRoZSB0ZXh0CnRleHRfbGVuZ3RoPSR7I3RleHR9CgojIEhpZGUgdGhlIGN1cnNvcgp0cHV0IGNpdmlzCgojIFRyYXAgQ1RSTCtDIHRvIHNob3cgdGhlIGN1cnNvciBiZWZvcmUgZXhpdGluZwp0cmFwICJ0cHV0IGNub3JtOyBleGl0IiBTSUdJTlQKCiMgU2V0IGZyZXF1ZW5jeSBzY2FsaW5nIGZhY3RvcgpmcmVxPTAuMgoKIyBJbmZpbml0ZSBsb29wIGZvciBjb250aW51b3VzIGFuaW1hdGlvbgpmb3IgKCggdD0wOyA7IHQrPTEgKSk7IGRvCiAgICAjIEV4dHJhY3Qgb25lIGNoYXJhY3RlciBhdCBhIHRpbWUKICAgIGNoYXI9IiR7dGV4dDp0ICUgdGV4dF9sZW5ndGg6MX0iCiAgICAKICAgICMgQ2FsY3VsYXRlIHRoZSBhbmdsZSBpbiByYWRpYW5zCiAgICBhbmdsZT0kKGVjaG8gIigkdCkgKiAkZnJlcSIgfCBiYyAtbCkKCiAgICAjIENhbGN1bGF0ZSB0aGUgc2luZSBvZiB0aGUgYW5nbGUKICAgIHNpbmVfdmFsdWU9JChlY2hvICJzKCRhbmdsZSkiIHwgYmMgLWwpCgogICAgIyBDYWxjdWxhdGUgeCBwb3NpdGlvbiB1c2luZyB0aGUgc2luZSB2YWx1ZQogICAgeD0kKGVjaG8gIigkY29scyAvIDIpICsgKCRjb2xzIC8gNCkgKiAkc2luZV92YWx1ZSIgfCBiYyAtbCkKICAgIHg9JChwcmludGYgIiUuMGYiICIkeCIpCgogICAgIyBFbnN1cmUgeCBpcyB3aXRoaW4gdGVybWluYWwgYm91bmRzCiAgICBpZiAoKCB4IDwgMCApKTsgdGhlbiB4PTA7IGZpCiAgICBpZiAoKCB4ID49IGNvbHMgKSk7IHRoZW4geD0kKChjb2xzIC0gMSkpOyBmaQoKICAgICMgQ2FsY3VsYXRlIGNvbG9yIGdyYWRpZW50IGJldHdlZW4gMTIgKGN5YW4pIGFuZCAyMDggKG9yYW5nZSkKICAgIGNvbG9yX3N0YXJ0PTEyCiAgICBjb2xvcl9lbmQ9MjA4CiAgICBjb2xvcl9yYW5nZT0kKChjb2xvcl9lbmQgLSBjb2xvcl9zdGFydCkpCiAgICBjb2xvcj0kKChjb2xvcl9zdGFydCArIChjb2xvcl9yYW5nZSAqIHQgLyBsaW5lcykgJSBjb2xvcl9yYW5nZSkpCgogICAgIyBQcmludCB0aGUgY2hhcmFjdGVyIHdpdGggMjU2LWNvbG9yIHN1cHBvcnQKICAgIGVjaG8gLW5lICJcMDMzWzM4OzU7JHtjb2xvcn1tIiQodHB1dCBjdXAgJHQgJHgpIiRjaGFyXDAzM1swbSIKCiAgICAjIExpbmUgZmVlZCB0byBtb3ZlIGRvd253YXJkCiAgICBlY2hvICIiCgpkb25lCgo=
```

## The Script

[Pasting it into CyberChef like so](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)&input=SXlFdlltbHVMMkpoYzJnS0NpTWdRMjl1WjNKaGRIVnNZWFJwYjI1eklTQlpiM1VnWm05MWJtUWdkR2hsSUdWaGMzUmxjaUJsWjJjaElPS2RwTys0andvaklPT0JpdU9DZ2VPQnArT0JxT09CaHVPQmxPT0JsdU9CaE9PQnZ1T0JtZSs4Z2VtYW9PT0JsZU9Dak9PQm4rT0N0ZU9EbCtPRHFlT0NwT09DdXVPQ2t1aW1pK09CcE9PQmtlT0J2dU9CbCtPQm4rKzhnZUtkcE8rNGp3b0tJeUJFWldacGJtVWdkR2hsSUhSbGVIUWdkRzhnWVc1cGJXRjBaUXAwWlhoMFBTTGltYVZRUlVGRFJlS1pwVVpQVXVLWnBVRk1UT0tacFZCRlFVTkY0cG1sUms5UzRwbWxRVXhNNHBtbFVFVkJRMFhpbWFWR1QxTGltYVZCVEV6aW1hVlFSVUZEUmVLWnBVWlBVdUtacFVGTVRPS1pwVkJGUVVORjRwbWxSazlTNHBtbFFVeE00cG1sSWdvS0l5QkhaWFFnZEdWeWJXbHVZV3dnWkdsdFpXNXphVzl1Y3dwamIyeHpQU1FvZEhCMWRDQmpiMnh6S1Fwc2FXNWxjejBrS0hSd2RYUWdiR2x1WlhNcENnb2pJRU5oYkdOMWJHRjBaU0IwYUdVZ2JHVnVaM1JvSUc5bUlIUm9aU0IwWlhoMENuUmxlSFJmYkdWdVozUm9QU1I3STNSbGVIUjlDZ29qSUVocFpHVWdkR2hsSUdOMWNuTnZjZ3AwY0hWMElHTnBkbWx6Q2dvaklGUnlZWEFnUTFSU1RDdERJSFJ2SUhOb2IzY2dkR2hsSUdOMWNuTnZjaUJpWldadmNtVWdaWGhwZEdsdVp3cDBjbUZ3SUNKMGNIVjBJR051YjNKdE95QmxlR2wwSWlCVFNVZEpUbFFLQ2lNZ1UyVjBJR1p5WlhGMVpXNWplU0J6WTJGc2FXNW5JR1poWTNSdmNncG1jbVZ4UFRBdU1nb0tJeUJKYm1acGJtbDBaU0JzYjI5d0lHWnZjaUJqYjI1MGFXNTFiM1Z6SUdGdWFXMWhkR2x2YmdwbWIzSWdLQ2dnZEQwd095QTdJSFFyUFRFZ0tTazdJR1J2Q2lBZ0lDQWpJRVY0ZEhKaFkzUWdiMjVsSUdOb1lYSmhZM1JsY2lCaGRDQmhJSFJwYldVS0lDQWdJR05vWVhJOUlpUjdkR1Y0ZERwMElDVWdkR1Y0ZEY5c1pXNW5kR2c2TVgwaUNpQWdJQ0FLSUNBZ0lDTWdRMkZzWTNWc1lYUmxJSFJvWlNCaGJtZHNaU0JwYmlCeVlXUnBZVzV6Q2lBZ0lDQmhibWRzWlQwa0tHVmphRzhnSWlna2RDa2dLaUFrWm5KbGNTSWdmQ0JpWXlBdGJDa0tDaUFnSUNBaklFTmhiR04xYkdGMFpTQjBhR1VnYzJsdVpTQnZaaUIwYUdVZ1lXNW5iR1VLSUNBZ0lITnBibVZmZG1Gc2RXVTlKQ2hsWTJodklDSnpLQ1JoYm1kc1pTa2lJSHdnWW1NZ0xXd3BDZ29nSUNBZ0l5QkRZV3hqZFd4aGRHVWdlQ0J3YjNOcGRHbHZiaUIxYzJsdVp5QjBhR1VnYzJsdVpTQjJZV3gxWlFvZ0lDQWdlRDBrS0dWamFHOGdJaWdrWTI5c2N5QXZJRElwSUNzZ0tDUmpiMnh6SUM4Z05Da2dLaUFrYzJsdVpWOTJZV3gxWlNJZ2ZDQmlZeUF0YkNrS0lDQWdJSGc5SkNod2NtbHVkR1lnSWlVdU1HWWlJQ0lrZUNJcENnb2dJQ0FnSXlCRmJuTjFjbVVnZUNCcGN5QjNhWFJvYVc0Z2RHVnliV2x1WVd3Z1ltOTFibVJ6Q2lBZ0lDQnBaaUFvS0NCNElEd2dNQ0FwS1RzZ2RHaGxiaUI0UFRBN0lHWnBDaUFnSUNCcFppQW9LQ0I0SUQ0OUlHTnZiSE1nS1NrN0lIUm9aVzRnZUQwa0tDaGpiMnh6SUMwZ01Ta3BPeUJtYVFvS0lDQWdJQ01nUTJGc1kzVnNZWFJsSUdOdmJHOXlJR2R5WVdScFpXNTBJR0psZEhkbFpXNGdNVElnS0dONVlXNHBJR0Z1WkNBeU1EZ2dLRzl5WVc1blpTa0tJQ0FnSUdOdmJHOXlYM04wWVhKMFBURXlDaUFnSUNCamIyeHZjbDlsYm1ROU1qQTRDaUFnSUNCamIyeHZjbDl5WVc1blpUMGtLQ2hqYjJ4dmNsOWxibVFnTFNCamIyeHZjbDl6ZEdGeWRDa3BDaUFnSUNCamIyeHZjajBrS0NoamIyeHZjbDl6ZEdGeWRDQXJJQ2hqYjJ4dmNsOXlZVzVuWlNBcUlIUWdMeUJzYVc1bGN5a2dKU0JqYjJ4dmNsOXlZVzVuWlNrcENnb2dJQ0FnSXlCUWNtbHVkQ0IwYUdVZ1kyaGhjbUZqZEdWeUlIZHBkR2dnTWpVMkxXTnZiRzl5SUhOMWNIQnZjblFLSUNBZ0lHVmphRzhnTFc1bElDSmNNRE16V3pNNE96VTdKSHRqYjJ4dmNuMXRJaVFvZEhCMWRDQmpkWEFnSkhRZ0pIZ3BJaVJqYUdGeVhEQXpNMXN3YlNJS0NpQWdJQ0FqSUV4cGJtVWdabVZsWkNCMGJ5QnRiM1psSUdSdmQyNTNZWEprQ2lBZ0lDQmxZMmh2SUNJaUNncGtiMjVsQ2dvPQ&oenc=65001) to decode Base64 back to plaintext, you'll get this:

```
#!/bin/bash

# Congratulations! You found the easter egg! ❤️
# おめでとうございます！隠されたサプライズを見つけました！❤️

# Define the text to animate
text="♥PEACE♥FOR♥ALL♥PEACE♥FOR♥ALL♥PEACE♥FOR♥ALL♥PEACE♥FOR♥ALL♥PEACE♥FOR♥ALL♥"

# Get terminal dimensions
cols=$(tput cols)
lines=$(tput lines)

# Calculate the length of the text
text_length=${#text}

# Hide the cursor
tput civis

# Trap CTRL+C to show the cursor before exiting
trap "tput cnorm; exit" SIGINT

# Set frequency scaling factor
freq=0.2

# Infinite loop for continuous animation
for (( t=0; ; t+=1 )); do
    # Extract one character at a time
    char="${text:t % text_length:1}"
    
    # Calculate the angle in radians
    angle=$(echo "($t) * $freq" | bc -l)

    # Calculate the sine of the angle
    sine_value=$(echo "s($angle)" | bc -l)

    # Calculate x position using the sine value
    x=$(echo "($cols / 2) + ($cols / 4) * $sine_value" | bc -l)
    x=$(printf "%.0f" "$x")

    # Ensure x is within terminal bounds
    if (( x < 0 )); then x=0; fi
    if (( x >= cols )); then x=$((cols - 1)); fi

    # Calculate color gradient between 12 (cyan) and 208 (orange)
    color_start=12
    color_end=208
    color_range=$((color_end - color_start))
    color=$((color_start + (color_range * t / lines) % color_range))

    # Print the character with 256-color support
    echo -ne "\033[38;5;${color}m"$(tput cup $t $x)"$char\033[0m"

    # Line feed to move downward
    echo ""

done
```

Which, when you insert it along with `eval "$(base64 -d <<< '<base64 string>')"` will execute the bash script. Note the shirt does mention it's a bash script, so I had to switch from `zsh` to `bash`. Ignoring the 'PEACE FOR ALL' text at the end, this is the 'one-liner':

```
#!/bin/bash 
eval "$(base64 -d <<< 'IyEvYmluL2Jhc2gKCiMgQ29uZ3JhdHVsYXRpb25zISBZb3UgZm91bmQgdGhlIGVhc3RlciBlZ2chIOKdpO+4jwojIOOBiuOCgeOBp+OBqOOBhuOBlOOBluOBhOOBvuOBme+8gemaoOOBleOCjOOBn+OCteODl+ODqeOCpOOCuuOCkuimi+OBpOOBkeOBvuOBl+OBn++8geKdpO+4jwoKIyBEZWZpbmUgdGhlIHRleHQgdG8gYW5pbWF0ZQp0ZXh0PSLimaVQRUFDReKZpUZPUuKZpUFMTOKZpVBFQUNF4pmlRk9S4pmlQUxM4pmlUEVBQ0XimaVGT1LimaVBTEzimaVQRUFDReKZpUZPUuKZpUFMTOKZpVBFQUNF4pmlRk9S4pmlQUxM4pmlIgoKIyBHZXQgdGVybWluYWwgZGltZW5zaW9ucwpjb2xzPSQodHB1dCBjb2xzKQpsaW5lcz0kKHRwdXQgbGluZXMpCgojIENhbGN1bGF0ZSB0aGUgbGVuZ3RoIG9mIHRoZSB0ZXh0CnRleHRfbGVuZ3RoPSR7I3RleHR9CgojIEhpZGUgdGhlIGN1cnNvcgp0cHV0IGNpdmlzCgojIFRyYXAgQ1RSTCtDIHRvIHNob3cgdGhlIGN1cnNvciBiZWZvcmUgZXhpdGluZwp0cmFwICJ0cHV0IGNub3JtOyBleGl0IiBTSUdJTlQKCiMgU2V0IGZyZXF1ZW5jeSBzY2FsaW5nIGZhY3RvcgpmcmVxPTAuMgoKIyBJbmZpbml0ZSBsb29wIGZvciBjb250aW51b3VzIGFuaW1hdGlvbgpmb3IgKCggdD0wOyA7IHQrPTEgKSk7IGRvCiAgICAjIEV4dHJhY3Qgb25lIGNoYXJhY3RlciBhdCBhIHRpbWUKICAgIGNoYXI9IiR7dGV4dDp0ICUgdGV4dF9sZW5ndGg6MX0iCiAgICAKICAgICMgQ2FsY3VsYXRlIHRoZSBhbmdsZSBpbiByYWRpYW5zCiAgICBhbmdsZT0kKGVjaG8gIigkdCkgKiAkZnJlcSIgfCBiYyAtbCkKCiAgICAjIENhbGN1bGF0ZSB0aGUgc2luZSBvZiB0aGUgYW5nbGUKICAgIHNpbmVfdmFsdWU9JChlY2hvICJzKCRhbmdsZSkiIHwgYmMgLWwpCgogICAgIyBDYWxjdWxhdGUgeCBwb3NpdGlvbiB1c2luZyB0aGUgc2luZSB2YWx1ZQogICAgeD0kKGVjaG8gIigkY29scyAvIDIpICsgKCRjb2xzIC8gNCkgKiAkc2luZV92YWx1ZSIgfCBiYyAtbCkKICAgIHg9JChwcmludGYgIiUuMGYiICIkeCIpCgogICAgIyBFbnN1cmUgeCBpcyB3aXRoaW4gdGVybWluYWwgYm91bmRzCiAgICBpZiAoKCB4IDwgMCApKTsgdGhlbiB4PTA7IGZpCiAgICBpZiAoKCB4ID49IGNvbHMgKSk7IHRoZW4geD0kKChjb2xzIC0gMSkpOyBmaQoKICAgICMgQ2FsY3VsYXRlIGNvbG9yIGdyYWRpZW50IGJldHdlZW4gMTIgKGN5YW4pIGFuZCAyMDggKG9yYW5nZSkKICAgIGNvbG9yX3N0YXJ0PTEyCiAgICBjb2xvcl9lbmQ9MjA4CiAgICBjb2xvcl9yYW5nZT0kKChjb2xvcl9lbmQgLSBjb2xvcl9zdGFydCkpCiAgICBjb2xvcj0kKChjb2xvcl9zdGFydCArIChjb2xvcl9yYW5nZSAqIHQgLyBsaW5lcykgJSBjb2xvcl9yYW5nZSkpCgogICAgIyBQcmludCB0aGUgY2hhcmFjdGVyIHdpdGggMjU2LWNvbG9yIHN1cHBvcnQKICAgIGVjaG8gLW5lICJcMDMzWzM4OzU7JHtjb2xvcn1tIiQodHB1dCBjdXAgJHQgJHgpIiRjaGFyXDAzM1swbSIKCiAgICAjIExpbmUgZmVlZCB0byBtb3ZlIGRvd253YXJkCiAgICBlY2hvICIiCgpkb25lCgo=')"
```

## The Result

Here's the result as an ASCII Cinema recording!

<link href="
https://cdn.jsdelivr.net/npm/asciinema-player@3.13.5/dist/bundle/asciinema-player.min.css" rel="stylesheet">

<script src="https://cdn.jsdelivr.net/npm/asciinema-player@3.13.5/dist/bundle/asciinema-player.min.js
"></script>
<div id="demo"></div>
<script>
    AsciinemaPlayer.create('/images/blog/akamai-uniqlo.cast', document.getElementById('demo'));
</script>

The animation is done by having the bash script run some calculation of the terminal size, hiding the cursor, and then using `bc` a [precision numeric processing language](https://www.gnu.org/software/bc/) to generate angles and sine values. `bc` was pre-installed on MacOS, at least [this version](https://github.com/gavinhoward/bc) was.

## Extras

If you're curious on how I recorded this didn't use a GIF: I used `asciinema`, which you can download [here](https://docs.asciinema.org/getting-started/).

I used a static binary instead of installing it, and I needed to explicitly call for `bash` otherwise it would default to `zsh` and result in `zsh: unrecognized modifier`.

- To record: `./asciinema rec akamai-uniqlo.cast --command="bash"`
- Then playback: `./asciinema play akamai-uniqlo.cast`
- And upload with `upload`, but I want >7 days without an account so I semi self-hosted by uploading the cast to my assets and used JS served by a CDN.