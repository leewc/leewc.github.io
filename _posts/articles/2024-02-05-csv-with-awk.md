---             
title: How to process CSV with Awk          
# excerpt .. and invoke an external command
tags: [tutorial, shell]
date: 2024-02-05
modified: 2024-02-10
---             

# TL;DR

Awk allows you to set a command as a variable, execute it and collect the output in another variable for further processing. But you'll have to mess around and be weary of different versions of awk. So, a lot of back and forth with StackOverflow or GPT. 

# Problem

CSV is super portable and often the format many developers reach for as it plays well with tools ranging from Excel and Quip, all the way down to terminal tools, as well as major programming languages that support comma separated values. 

Given a CSV (comma separated value) file like so:

```bash
cat example.csv

jane,1,10
john,2,30
alice,5,10
bob,6,90
```

I had a use case to invoke an external command, or to 'shell-out' and append the result into another column. 

For the purpose of this blog, let's say we had a script, `md5.sh` that would either accept input from `stdin` or as the first `$1` parameter.

```bash
#!/bin/bash
if [ -p /dev/stdin ]; then
    while read line; do
        # cut removes the '-' on the md5sum output
        printf "%s" "$line" | md5sum | cut -d' ' -f1 
    done
else
    if [ $# -eq 1 ]; then
        printf "%s" "$1" | md5sum | cut -d' ' -f1
    fi
fi
```

My initial instinct was to do a `cut` to extract the column I want to run a command for, for the purpose of this article let's assume I needed to use `md5sum`. And we'd extract the first column (so jane, john, alice, bob)

It would go something like:

```bash
$ cat example.csv | cut -d, -f 1 | ./md5.sh

5844a15e76563fedd11840fd6f40ea7b
527bd5b5d689e2c32ae974c6229ff785
6384e2b2184bcbf58eccf10ca7a6563c
9f9d51bc70ef21ca5c14f307980a29d8
```

(*Note*: I can use `md5sum`, but `md5sum` receives the entire input, new lines and all, hence I have to break it up. You also get a `-` in the output. In my original use-case the command I was going to invoke simply processes line by line and outputs a result per-line. Without the script above, you'd need the extra while loops: `cat example.csv | cut -d, -f 1 | while read -r line; do echo -n $line | md5sum; done`)

Then with that md5 output, I'd typically give up on the terminal, pop on VSCode or Sublime Text, or even Excel, and *copy and paste* the output as a new column.

But that's no fun! Getting some help from ChatGPT taught me about Awk allowing you to invoke a command as a variable during the output!

```bash
awk -F',' '{ cmd="command_to_invoke" cmd $0 | getline result; close(cmd); print result","$0","$1}'
```

Giving credit to GPT3.5 Turbo: 
> Within awk, we assign `command_to_invoke` to variable cmd. Then, we use `getline` with variable `result` and pipe it into `cmd`. After that, we `close(cmd)`. Finally, we print each line followed by a comma and value of field 1 ($0","result). 

Awk for years has been daunting to me, so slowly breaking it down helps.

So using MD5, it would look something like:

```bash
cat example.csv | awk -F',' '{ cmd="./md5.sh "; (cmd $0 | getline result); close(cmd); print $0","result}'
```

Then you'd get a very nice output!

```
jane,1,10,5844a15e76563fedd11840fd6f40ea7b
john,2,30,527bd5b5d689e2c32ae974c6229ff785
alice,5,10,6384e2b2184bcbf58eccf10ca7a6563c
bob,6,90,9f9d51bc70ef21ca5c14f307980a29d8

```

AWK itself has been confusing for me throughout the years. So breaking this down step by step:
 - `cat example.csv` will pipe out the contents of the file into AWK
 - `-F','` defines you want to separate the string on ','
 - `cmd="./md5.sh " ` creates a variable in awk and allows for commands to be executed. Note the extra space after the script name, it's necessary otherwise AWK will not leave a space in between the command and the value passed in.
 - `cmd $1` tells AWK to run the cmd variable with $1, which in our example above, be `jane`, `john`, `alice`, `bob`.
 - `| getline result` will store the output of the executed command (output of `md5.sh`)
 - `close(cmd)` simply closes the temporary files created
 - Finally, the print command dictates `$0` (the whole string), and `","` and the `"result"`


> Update 
> Turns out the command above might also include the return code, depending on the script and version of awk. Here's another one to try:
> `cat example.csv| awk -F',' '{ cmd="./md5.sh "$1 ;while ( ( cmd | getline result ) > 0 ) {print result","$0 } close(cmd)}'`

Hope this was helpful! 

But... there's more! If you actually tried following it along on your system, it might not work. What gives? Why did this random internet stranger lie to you?

```bash
$ cat example.csv | awk -F',' '{ cmd="./md5.sh " cmd $1 | getline result; close(cmd); print result }'
/bin/sh: 1: jane: not found

/bin/sh: 1: john: not found

/bin/sh: 1: alice: not found

/bin/sh: 1: bob: not found
```

Turns out, [there's multiple variants](https://www.baeldung.com/linux/awk-nawk-gawk-mawk-difference) of awk. Eg. `GNU Awk (gawk), mawk, awk (itself), nawk`.

One of these end up in your box as `awk`. When I was writing this blog post, I decided to test it out again as I go (so I don't waste your time, dear reader), and was stuck on this for the longest time (1.5 hours of me questioning if I missed a space somewhere or I wasn't escaping something right, as it was incorrectly treating `$1` as a command - According to `history` I tried over 290 times. sigh). The laptop I write on was similar compared to the host I had in the cloud in that it was GNU/Linux based, but the differences were way more! 

You will want to try `awk --version`. If you get this, then it might work for you.

```bash
awk --version

GNU Awk 5.1.0, API: 3.0 (GNU MPFR 4.1.0, GNU MP 6.2.1)
Copyright (C) 1989, 1991-2020 Free Software Foundation.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
```

On my laptop (and on my other system), I got 

```bash
$ awk --v
awk: not an option: --v

$ awk -W version

mawk 1.3.4 20200120
Copyright 2008-2019,2020, Thomas E. Dickey
Copyright 1991-1996,2014, Michael D. Brennan

random-funcs:       srandom/random
regex-funcs:        internal
compiled limits:
sprintf buffer      8192
maximum-integer     2147483647
```

It appears that different variants react differently. You can get GNU Awk if you're on a debian based system with `sudo apt-get install gawk`. It'll even override `mawk`!

This command `cat example.csv| awk -F',' '{ cmd="./md5.sh " cmd $1 | getline result; close(cmd); print $0","$result}'` worked for me on `GNU Awk 4.0.2`, while on the newer version I had to put parentheses correctly. So, play around... as I have timeboxed my attempts.

Finally, be weary about the CSV you handle, you are susceptible to [shell injection](https://stackoverflow.com/questions/56591462/are-these-awk-commands-vulnerable-to-code-injection) using awk.

## References

- [https://www.gnu.org/software/gawk/manual/html_node/Getline.html](https://www.gnu.org/software/gawk/manual/html_node/Getline.html)

- [https://www.gnu.org/software/gawk/manual/html_node/Getline_002fPipe.html](https://www.gnu.org/software/gawk/manual/html_node/Getline_002fPipe.html) --> See "Note" here on how different versions behave differently.

- [https://pmitev.github.io/to-awk-or-not/More_awk/Input_output/](https://pmitev.github.io/to-awk-or-not/More_awk/Input_output/)

- [https://stackoverflow.com/questions/1960895/assigning-system-commands-output-to-variable](https://stackoverflow.com/questions/1960895/assigning-system-commands-output-to-variable)

