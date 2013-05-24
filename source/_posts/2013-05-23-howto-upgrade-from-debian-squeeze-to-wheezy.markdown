---
layout: post
title: "Howto: Upgrade from Debian squeeze to wheezy"
date: 2013-05-23 10:46
comments: true
categories: 
---
This blog post will discuss how to upgrade from Debian squeeze to wheezy.

We'll start by cleaning a few things up.

{% codeblock Clear out local repository of retrieved package files no longer needed %}
apt-get autoclean
{% endcodeblock %}

{% codeblock Remove packages no longer needed %}
apt-get autoremove
{% endcodeblock %}

Now let's search for packages that have been installed only partially and fix them.
{% codeblock Fix any packages in the output of the dpkg cmd below %}
dpkg --audit
{% endcodeblock %}

Now make sure no packages are on hold like so:
{% codeblock Fix any packages that may be on hold %}
dpkg --get-selections | grep hold
{% endcodeblock %}

If you receive no output from the two dpkg commands above it should be safe to start the upgrade.

Update your source list located at /etc/apt/sources.list. If you're not on squeeze then substitute 'squeeze' with the version you're on.
{% codeblock Use sed to edit your list of sources %}
sed -i 's/squeeze/wheezy/g' /etc/apt/sources.list
{% endcodeblock %}

Your source list at /etc/apt/sources.list should now look something like the following:
{% codeblock New source list pointing at wheezy repos %}
server1:~# cat /etc/apt/sources.list
deb http://ftp.us.debian.org/debian/ squeeze main contrib non-free
deb-src http://ftp.us.debian.org/debian/ squeeze main contrib non-free

deb http://security.debian.org/ squeeze/updates main contrib non-free
deb-src http://security.debian.org/ squeeze/updates main contrib non-free

# squeeze-updates, previously known as 'volatile'
deb http://ftp.us.debian.org/debian/ squeeze-updates main contrib non-free
deb-src http://ftp.us.debian.org/debian/ squeeze-updates main contrib non-free
server1:~#   
{% endcodeblock %}

Note: Your URLs will likely differ from mine; especially if you don't live in the US.

Now let's resynchronize your package index files from the new sources that point to Wheezy.
{% codeblock Resynchronize package index files via apt-get update %}
server1:~# apt-get update
{% endcodeblock %}

Next install the newest versions of all packages currently installed on the system according to /etc/apt/sources.list.  
Note: This is pretty much the point of no return!
{% codeblock Install the newest versions of all packages currently installed %}
server1:~# apt-get upgrade
{% endcodeblock %}

Now actually upgrade your current Debian distribution. Apt-get dist-upgrade will perform the same as upgrade and intelligently handle changing dependencies
with new versions of packages.
{% codeblock Upgrade your Debian distribution %}
server1:~# apt-get dist-upgrade
{% endcodeblock %}

Now reboot.
{% codeblock Reboot into your new Debian distribution Wheezy %}
server1:~# init 6
{% endcodeblock %}

After logging back into your Debian box let's check for package issues like we did before.
{% codeblock Fix any packages these two commands output %}
server1:~# dpkg --audit 
server1:~# dpkg --get-selections | grep hold
{% endcodeblock %}

You may need to do the upgrade dist-upgrade song-and-dance one final time.
{% codeblock Do a final upgrade %}
server1:~# apt-get upgrade 
server1:~# apt-get dist-upgrade
{% endcodeblock %}

Finally check what Debian version you're currently on.
{% codeblock Check your Debian version %}
server1:~# cat /etc/debian_version 
7.0
server1:~# 
{% endcodeblock %}

If the output of the above command is 7.0 you are now running Debian Wheezy!

Now go have a beer or three!
