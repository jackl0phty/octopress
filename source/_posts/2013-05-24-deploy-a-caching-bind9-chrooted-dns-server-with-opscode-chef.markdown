---
layout: post
title: "Deploy a caching Bind9 CHROOTed DNS server with Opscode Chef"
date: 2013-05-24 19:53
comments: true
categories: 
---
This blog post will discuss how to use the industry leading configuration management tool [Chef](https://learnchef.opscode.com/), from [Opscode](http://www.opscode.com/), to deploy a caching Bind9
DNS server installed in a CHROOT jail environment.

First download and install my bind-chroot cookbook from within your main chef-repo like so:
{% codeblock Install my bind-chroot cookbook from the community site %}
skywalker@laptop ~/chef-repo/ $ knife cookbook site install bind-chroot
{% endcodeblock %}

Include the bind-chroot::chroot recipe in your node's runlist like so:
{% codeblock Add bind-chroot::chroot recipe to your node's runlist %}
{
    "normal": {
    },
    "name": "dns1",
    "chef_environment": "production",
    "override": {
    },
	"production": {
    },
    "json_class": "Chef::Node",
    "automatic": {
    },
    "run_list": [
	"recipe[bind-chroot::chroot]"

    ],
    "chef_type": "node"
}
{% endcodeblock %}

Update your node's definition like so:
{% codeblock Update your node's definition %}
skywaler@laptop ~/chef-repo/ $ knife node from file nodes/dns1.json
Updated Node dns1!
skywalker@laptop ~/chef-repo/ $
{% endcodeblock %}

Now run chef-client on the node you want to deploy bind9 to like so:
{% codeblock Run chef-client on node you want to install bind9 on %}
dns1 ~ # chef-client
Starting Chef Client, version 11.4.4
[2013-05-28T13:02:51-04:00] INFO: *** Chef 11.4.4 ***
{% endcodeblock %}

If all went well named should now be installed in a CHROOT, jailed to /var/bind9/chroot, & listening.
We can check if named is listening with netstat like so:
{% codeblock %}
glh-laptop2 etc # netstat -nlp |grep named
tcp        0      0 10.102.180.85:53        0.0.0.0:*               LISTEN      6057/named      
tcp        0      0 127.0.0.1:53            0.0.0.0:*               LISTEN      6057/named      
tcp        0      0 127.0.0.1:953           0.0.0.0:*               LISTEN      6057/named      
tcp6       0      0 :::53                   :::*                    LISTEN      6057/named      
tcp6       0      0 ::1:953                 :::*                    LISTEN      6057/named      
udp        0      0 10.102.180.85:53        0.0.0.0:*                           6057/named      
udp        0      0 127.0.0.1:53            0.0.0.0:*                           6057/named      
udp6       0      0 :::53                   :::*                                6057/named      
{% endcodeblock %}

As you can see from the netstat output above, named is listening on TCP and UDP ports 53.

By default Bind9, on Debian & derivatives, is already configured as a "caching only" name server.

Let's test Bind9's caching by looking up a domain, say google.com, with our dns client dig like so
{% codeblock %}
dns1 ~ # dig google.com @localhost

; <<>> DiG 9.9.2-P1 <<>> google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 53144
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		46	IN	A	74.125.228.98
google.com.		46	IN	A	74.125.228.97
google.com.		46	IN	A	74.125.228.104
google.com.		46	IN	A	74.125.228.96
google.com.		46	IN	A	74.125.228.110
google.com.		46	IN	A	74.125.228.100
google.com.		46	IN	A	74.125.228.105
google.com.		46	IN	A	74.125.228.103
google.com.		46	IN	A	74.125.228.102
google.com.		46	IN	A	74.125.228.101
google.com.		46	IN	A	74.125.228.99

;; AUTHORITY SECTION:
google.com.		4587	IN	NS	ns3.google.com.
google.com.		4587	IN	NS	ns4.google.com.
google.com.		4587	IN	NS	ns2.google.com.
google.com.		4587	IN	NS	ns1.google.com.

;; ADDITIONAL SECTION:
ns2.google.com.		69375	IN	A	216.239.34.10
ns1.google.com.		69375	IN	A	216.239.32.10
ns3.google.com.		75822	IN	A	216.239.36.10
ns4.google.com.		69375	IN	A	216.239.38.10

;; Query time: 26 msec
;; SERVER: 10.101.4.36#53(10.101.4.36)
;; WHEN: Tue May 28 15:45:38 2013
;; MSG SIZE  rcvd: 351

dns1 ~ # 
{% endcodeblock %}

Note the line containing "Query time" shows our query took 26 milliseconds to complete.
Now the domain google.com should be cached so let's do another query and see if our time improves.
{% codeblock %}
dns1 ~ # dig google.com @localhost

; <<>> DiG 9.9.2-P1 <<>> google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18367
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		251	IN	A	74.125.228.105
google.com.		251	IN	A	74.125.228.99
google.com.		251	IN	A	74.125.228.96
google.com.		251	IN	A	74.125.228.102
google.com.		251	IN	A	74.125.228.98
google.com.		251	IN	A	74.125.228.97
google.com.		251	IN	A	74.125.228.101
google.com.		251	IN	A	74.125.228.110
google.com.		251	IN	A	74.125.228.103
google.com.		251	IN	A	74.125.228.100
google.com.		251	IN	A	74.125.228.104

;; AUTHORITY SECTION:
google.com.		11118	IN	NS	ns3.google.com.
google.com.		11118	IN	NS	ns1.google.com.
google.com.		11118	IN	NS	ns4.google.com.
google.com.		11118	IN	NS	ns2.google.com.

;; ADDITIONAL SECTION:
ns2.google.com.		75906	IN	A	216.239.34.10
ns1.google.com.		75906	IN	A	216.239.32.10
ns3.google.com.		82353	IN	A	216.239.36.10
ns4.google.com.		75906	IN	A	216.239.38.10

__;; Query time: 0 msec__
;; SERVER: 10.101.4.36#53(10.101.4.36)
;; WHEN: Tue May 28 13:56:48 2013
;; MSG SIZE  rcvd: 351

dns1 ~ etc #
{% endcodeblock %}

As you can see above our query took 0 milliseconds! That's obviously an improvement from our original query time of 26 milliseconds.

This record will be cached according to the TTL (Time To Live) of the zone record.

Let's do another query and suppress some of dig's output like so:
{% codeblock %}
dns1 ~ # dig +noauthority +noquestion +noadditional +nostats google.com @localhost

; <<>> DiG 9.9.2-P1 <<>> +noauthority +noquestion +noadditional +nostats google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48993
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; ANSWER SECTION:
google.com.		300	IN	A	173.194.43.5
google.com.		300	IN	A	173.194.43.9
google.com.		300	IN	A	173.194.43.14
google.com.		300	IN	A	173.194.43.8
google.com.		300	IN	A	173.194.43.0
google.com.		300	IN	A	173.194.43.4
google.com.		300	IN	A	173.194.43.2
google.com.		300	IN	A	173.194.43.3
google.com.		300	IN	A	173.194.43.1
google.com.		300	IN	A	173.194.43.7
google.com.		300	IN	A	173.194.43.6
{% endcodeblock %}
The number 300 from the above dig output is the __time remaining until the DNS cache will be updated__ in seconds.  Since this is our caching nameserver if we wait a few seconds/minutes and do another query this number should decrease like in the output below:
{% codeblock %}
dns1 1 # dig +noauthority +noquestion +noadditional +nostats google.com @localhost

; <<>> DiG 9.9.2-P1 <<>> +noauthority +noquestion +noadditional +nostats google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18942
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; ANSWER SECTION:
google.com.		47	IN	A	173.194.43.3
google.com.		47	IN	A	173.194.43.4
google.com.		47	IN	A	173.194.43.1
google.com.		47	IN	A	173.194.43.6
google.com.		47	IN	A	173.194.43.8
google.com.		47	IN	A	173.194.43.7
google.com.		47	IN	A	173.194.43.0
google.com.		47	IN	A	173.194.43.14
google.com.		47	IN	A	173.194.43.9
google.com.		47	IN	A	173.194.43.5
google.com.		47	IN	A	173.194.43.2
{% endcodeblock %}
Notice time remaining until cache will be updated on our caching bind9 name server has now decreased from 300 seconds to 47 seconds.
So if we wait more then 47 seconds and do another query we should see a number much greater then 47.
{% codeblock %}
dns1 ~ # dig +noauthority +noquestion +noadditional +nostats google.com @localhost

; <<>> DiG 9.9.2-P1 <<>> +noauthority +noquestion +noadditional +nostats google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43033
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; ANSWER SECTION:
google.com.		300	IN	A	173.194.43.5
google.com.		300	IN	A	173.194.43.14
google.com.		300	IN	A	173.194.43.6
google.com.		300	IN	A	173.194.43.3
google.com.		300	IN	A	173.194.43.2
google.com.		300	IN	A	173.194.43.8
google.com.		300	IN	A	173.194.43.0
google.com.		300	IN	A	173.194.43.9
google.com.		300	IN	A	173.194.43.4
google.com.		300	IN	A	173.194.43.7
google.com.		300	IN	A	173.194.43.1
{% endcodeblock %}
As you can see time until cache will be updated is back up to 300 seconds or 5 minutes.

If we want to find the actuall TTL for google.com we'll need to query an authorative name server for google.com.
Let's get a list of authorative name servers with the following dig command like so:
{% codeblock %}
dns1 ~ # dig +authority +noquestion +noadditional +nostats +noanswer google.com @localhost

; <<>> DiG 9.9.2-P1 <<>> +authority +noquestion +noadditional +nostats +noanswer google.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18393
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; AUTHORITY SECTION:
google.com.		166915	IN	NS	ns4.google.com.
google.com.		166915	IN	NS	ns2.google.com.
google.com.		166915	IN	NS	ns3.google.com.
google.com.		166915	IN	NS	ns1.google.com.

dns1 ~ # 
{% endcodeblock %}
So from the above output we see that name server ns1.google.com is authorative for google.com.

If we query ns1.google.com we can get the actual TTL like so:
{% codeblock %}
skywalker@laptop ~ $ dig google.com @ns1.google.com

; <<>> DiG 9.9.2-P1 <<>> google.com @ns1.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57411
;; flags: qr aa rd; QUERY: 1, ANSWER: 11, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	173.194.43.14
google.com.		300	IN	A	173.194.43.8
google.com.		300	IN	A	173.194.43.3
google.com.		300	IN	A	173.194.43.4
google.com.		300	IN	A	173.194.43.6
google.com.		300	IN	A	173.194.43.5
google.com.		300	IN	A	173.194.43.7
google.com.		300	IN	A	173.194.43.9
google.com.		300	IN	A	173.194.43.2
google.com.		300	IN	A	173.194.43.1
google.com.		300	IN	A	173.194.43.0

;; Query time: 31 msec
;; SERVER: 216.239.32.10#53(216.239.32.10)
;; WHEN: Tue May 28 17:23:38 2013
;; MSG SIZE  rcvd: 204

skywalker@laptop ~ $ 
{% endcodeblock %}
Notice the TTL is 300.  Also notice the line containing "aa" following the line containing "HEADER" as shown below:
{% codeblock %}
;; flags: qr aa rd; QUERY: 1, ANSWER: 11, AUTHORITY: 0, ADDITIONAL: 0
{% endcodeblock %}
Notice the "aa".  This means this is an authorative answer for the domain google.com.

If we do another query you'll see the TTL remains 300 and doesn't change like it did against our own local bind9 server.
This is the actual TTL (Time To Live) for domain google.com since we queried an authorative name server.
{% codeblock %}
skywalker@laptop ~ $ dig google.com @ns1.google.com

; <<>> DiG 9.9.2-P1 <<>> google.com @ns1.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 14944
;; flags: qr aa rd; QUERY: 1, ANSWER: 11, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	173.194.43.6
google.com.		300	IN	A	173.194.43.9
google.com.		300	IN	A	173.194.43.3
google.com.		300	IN	A	173.194.43.1
google.com.		300	IN	A	173.194.43.8
google.com.		300	IN	A	173.194.43.0
google.com.		300	IN	A	173.194.43.7
google.com.		300	IN	A	173.194.43.4
google.com.		300	IN	A	173.194.43.2
google.com.		300	IN	A	173.194.43.5
google.com.		300	IN	A	173.194.43.14

;; Query time: 56 msec
;; SERVER: 216.239.32.10#53(216.239.32.10)
;; WHEN: Tue May 28 17:23:50 2013
;; MSG SIZE  rcvd: 204

skywaler@laptop ~ $ 
{% endcodeblock %}

We can now dump our DNS cache to file with the command below.  If you're using my [bind-chroot](http://community.opscode.com/cookbooks/bind-chroot) cookbook your cache file should be located at /var/bind9/chroot/var/cache/bind/named_dump.db.
{% codeblock %}
rndc dumpdb -cache
{% endcodeblock %}

We can now view the contents of our cache and look for google.com like so:
{% codeblock %}
cat /var/bind9/chroot/var/cache/bind/named_dump.db |grep google.com
google.com.		172385	NS	ns1.google.com.
			172385	NS	ns2.google.com.
			172385	NS	ns3.google.com.
			172385	NS	ns4.google.com.
ns1.google.com.		172385	A	216.239.32.10
ns2.google.com.		172385	A	216.239.34.10
ns3.google.com.		172385	A	216.239.36.10
ns4.google.com.		172385	A	216.239.38.10
skywalker@laptop ~ # rndc dumpdb -cache
{% endcodeblock %}

You can see, by default, bind9 cached google.com for ~172385 seconds or ~47 hours!
