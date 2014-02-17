---
layout: post
title: "How to Back Files up to S3 DevOPS Style With OpsChef"
date: 2013-09-19 19:43
comments: true
categories: 
---
This blog post will discuss how to copy files to Amazon's [simple storage service (S3)](http://aws.amazon.com/s3/) using
[Opscode Chef](http://www.getchef.com/).&nbsp;&nbsp;Awright, let's get krack-a-lackin!

This Blog Post Makes the Following Assumptions
----------------------------------------------

&nbsp;&nbsp;&nbsp;1.  You have successfully installed [chef-client](http://www.opscode.com/chef/install/).

&nbsp;&nbsp;&nbsp;2.  You have a working [knife config](http://docs.opscode.com/knife_configure.html).

&nbsp;&nbsp;&nbsp;3.  You have either a working [open source chef server](http://docs.opscode.com/install_server.html) or you're using [enterprise chef](http://www.opscode.com/enterprise-chef/).

&nbsp;&nbsp;&nbsp; Note: Enterprise Chef comes with __5 free nodes__!
<!-- more -->
So let's start off by installing my [amazon_s3cmd cookbook](http://community.opscode.com/cookbooks/amazon_s3cmd) like so:
{% codeblock %}
luke@alderaan:~ $ knife cookbook site install amazon_s3cmd
{% endcodeblock %}
Next you'll need a secret key for your databag.
{% codeblock %}
luke@alderaan:~ $ openssl rand -base64 512 > data_bag_secret_key
{% endcodeblock %}
Now create a new data bag item that will be used.
{% codeblock %}
skywalker@alderaan:~/your/chef-repo$ knife data bag create  --secret-file ~/data_bag_secret_key s3cmd s3cfg 
Created data_bag[s3cmd] 
Created data_bag_item[s3cfg] 
{% endcodeblock %}
If you get the following error below...
{% codeblock %}
ERROR: RuntimeError: Please set EDITOR environment variable
{% endcodeblock %}
..make sure you export your editor as EDITOR
{% codeblock %}
export EDITOR=vim
{% endcodeblock %}
Verify your encrypted data bag items.
{% codeblock %}
skywaler@alderaan:~/your/chef-repo$ knife data bag show s3cmd s3cfg 
id:            s3cfg 
s3_access_key: 
  cipher:         aes-256-cbc 
  encrypted_data:  BUNCH_OF_RANDOM_CHARS_HERE

iv: RANDOM_CHARS_HERE

version: 1 s3_secret_key: cipher: aes-256-cbc encrypted_data: BUNCH_OF_RANDOM_CHARS_HERE

iv: RANDOM_CHARS_HERE

version: 1 skywaler@alderaan:~/your/chef-repo$ 
{% endcodeblock %}
Now check your decrypted data bag items
{% codeblock %}
skywaler@alderaan:~/your/chef-repo$ knife data bag show –secret-file=/home/you/data_bag_secret_key s3cmd s3cfg 
id:            s3cfg 
s3_access_key: YOUR_ACCESS_KEY_HERE
s3_secret_key: YOUR_SECRET_KEY_HERE
{% endcodeblock %}
Copy your secret key to your node.
{% codeblock %}
skywalker@alderaan:~ $ scp /home/you/data_bag_secret_key skywalker@alderaan: 
skywalker@alderaan's password: 
data_bag_secret_key 
{% endcodeblock %}
Move your key to /etc/chef.
{% codeblock %}
skywalker@alderaan:~ $ sudo mv /home/skywalker/data_bag_secret_key /etc/chef/
{% endcodeblock %}
Include the `amazon_s3cmd::source` recipe in your node's run_list if you want the latest beta version which supports adavnced features:
{% codeblock %}
{
  "name":"my_node",
  "run_list": [
    "recipe[amazon_s3cmd::source]"
  ]
}
{% endcodeblock %}
Run chef-client on your node to update it's configuration and install & configure s3cmd like so:
{% codeblock %}
skywalker@alderaan:~ $ sudo chef-client
{% endcodeblock %}
Confirm your s3cmd configuration
================================
If you took the defaults, your s3cmd's config file will be located at `/root/.s3cfg` and should look something like the following:
{% codeblock %}
skywalker@alderaan:~# sudo cat /root/.s3cfg 
[default]
access_key = YOUR_ACCESS_KEY_HERE!
bucket_location = US
cloudfront_host = cloudfront.amazonaws.com
default_mime_type = binary/octet-stream
delete_removed = False
dry_run = False
enable_multipart = True
encoding = UTF-8
encrypt = False
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase =
guess_mime_type = True
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com
human_readable_sizes = False
invalidate_on_cf = False
list_md5 = False
log_target_prefix =
mime_type =
multipart_chunk_size_mb = 15
preserve_attrs = True
progress_meter = True
proxy_host =
proxy_port = 0
recursive = False
recv_chunk = 4096
reduced_redundancy = False
secret_key = YOUR_SECRET_KEY_HERE!
send_chunk = 4096
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 300
urlencoding_mode = normal
use_https = True
verbosity = WARNING
website_endpoint = http://%(bucket)s.s3-website-%(location)s.amazonaws.com/
website_error =
website_index = index.html
{% endcodeblock %}

BACK YO STUFF UP
----------------
If you made it this far; CONGRATS! You should now be ready to back files up to S3.

So, for example, let's say you have some backups in /mnt/backups you'd like to tar up and copy to S3.
{% codeblock %}
skywalker@alderaan:~# ls /mnt/backups/
backup1.tar.gz	backup2.tar.gz
{% endcodeblock %}

You can tar up your backups like so:
{% codeblock %}
skywalker@alderaan:~# tar zcvhf /tmp/backups.tar.gz /mnt/backups
tar: Removing leading `/' from member names
/mnt/backups/
/mnt/backups/backup1.tar.gz
/mnt/backups/backup2.tar.gz
jackl0phty:~# ls -alh /tmp/backups.tar.gz 
-rw-r--r-- 1 root root 167 Dec 19 19:05 /tmp/backups.tar.gz
{% endcodeblock %}

As you can see above, this will create a tar archive of the /mnt/backups directory and save it as /tmp/backups.tar.gz.

Next, let's create an S3 bucket that we can use to copy our backups to like so:
{% codeblock %}
skywalker@alderaan:~# s3cmd mb s3://jackl0phty-backups
{% endcodeblock %}

Now, copy your backup to your S3 bucket:
{% codeblock %}
skywalker@alderaan:~# s3cmd put /tmp/backups.tar.gz s3://jackl0phty-backups
{% endcodeblock %}

Finally, you should now be able to display the contents of your bucket like so:
{% codeblock %}
skywalker@alderaan:~# s3cmd ls /tmp/backups.tar.gz s3://jackl0phty-backups
{% endcodeblock %}

Contributing
============
You'd like to contribute? That's freaking awesome! Here's how.

1. Fork the repository on Github by clicking [here](https://github.com/jackl0phty/opschef-cookbook-amazon_s3cmd/fork).
2. Create a topic branch (like `yourname-add-awesomeness`).
3. Write you change.
4. Write tests for your change (if applicable).
5. Run the tests, ensuring they all pass.
6. Submit a Pull Request using Github [here](https://github.com/jackl0phty/opschef-cookbook-amazon_s3cmd).
