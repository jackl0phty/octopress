---
layout: post
title: "Using Perl to Print Avery Labels"
date: 2013-01-18 23:41
author: Gerald L. Hevener Jr. M.S.
comments: true
categories: 
---
This blog will discuss how to use the Perl module PostScript::MailLabels to print Avery labels.

The basic design is to have your user(s) run the following BASH shell script, which will then call a Perl script that builds a postscript file, then the BASH script will send the postscript file to the printer.

Here is the shell script your user(s) will run.
{% codeblock Set Linux Environment to Print Avery Labels lang:bash https://gist.github.com/jackl0phty/4247878/raw/be2223e3cf561c4db010a30fc95de558291df5fa/perl-avery-labels %}
#!/bin/bash
 
###############################################################################
# This shell script can be used to print Avery                                #
# address labels.                                                             #
###############################################################################
# Licensed under the Apache License, Version 2.0 (the "License"),             #
# For any questions regarding the license of this software, please refer to   #
# the actual license at http://www.apache.org/licenses/LICENSE-2.0.txt.       #
###############################################################################
#                      DISCLAIMER OF WARRENTY                                 #
# BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR  #
# THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN        #
# OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES      #
# PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED #
# OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF        #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO #
# THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE         #
# SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,   #
# REPAIR, OR CORRECTION. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR     #
# AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY  #
# MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE,  #
# BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,   #
# OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE     #
# SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED  #
# INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIESOR A FAILURE OF THE   #
# SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER  #
# PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.                  #
###############################################################################
 
# Must export default printer environment variable
# in order for lpr to function correctly. The rest
# will be executed from a Perl script.

#declare variables
FILEPATH="/home/user1/"
DATE=`date +%m%d%y`
MYPERL=`which perl`
SCRIPT=${FILEPATH}'print_addresses.pl'
 
# Get name of file user wants to process
echo "What printer do you want to print to?"
read PRINTER
 
#echo "Going to process: $DEFAULTPRINTER"
 
# Set default printer to DEFAULTPRINTER
export PRINTER=$PRINTER
 
# Call perl script which builds a postscript
# file and sends it to user's printer.
perl $SCRIPT
 
# Send postscript file to the printer
`cat ${FILEPATH}$DATE | lpr -P $PRINTER`
 
exit 0
{% endcodeblock %}

The BASH script basically asks the user what printer they want to print to,  set's the user's DEFAULT printer, then calls your Perl script using the module PostScript::MailLabels to build a postscript file, then the BASH script  sends it to the user's printer.

Here is the Perl script which does most of the heavy lifting.

{% codeblock Make a secure connection via SSH lang:perl https://gist.github.com/jackl0phty/4247908/raw/e408e56504ec079bf7975e504a43bdaa37c720b3/Perl-Print-Avery-Labels %}
 #!/usr/bin/perl
##################################################
#This script is responsible for making a secure  #
#connection via ssh to server1 and executing the #
#commaned ls .                                   #
#This script is also responsible for making a    #
#a secure connection via ssh to server1 and then #
#scp the file test.txt.                          #
##################################################

#import required modules
use strict;
use warnings;
use Net::SCP qw(scp iscp);
use Net::SSH qw(ssh);
use Log::Dispatch::Syslog;

#declare local variables
my $scp;
my $host = "server1.domain.com";
my $user = "user1";
my $remotedir = "/home/user1/";
my $file = "test.txt";
my $cmd = "/bin/ls";

####################Log::Dispatch::Syslog#######################################
# Define our pid for use in the log message
my $pid = getppid();
# Define our logfile object
my $logfile = Log::Dispatch::Syslog->new( name => 'logfile',
                                          min_level => 'info',
                                          ident => "running_list_cmd[$pid]" );
####################Log::Dispatch::Syslog#######################################

######first connect to $host via Net::SSH and run /bin/ls###########
$logfile->log( level => 'info', message => "Connecting to $host as $user and running /bin/ls ..." );
ssh("$user\@$host", $cmd);
$logfile->log( level => 'info', message => "ls completed successfully!" );
######first connect to $host via Net::SSH and copy file $file###########

#initialize Net::SCP object and send credentials
$scp = Net::SCP->new($host);

#notify user we're logging into $host
print "Logging into $host ...\n";

#write "connected to $host" to $file
$logfile->log( level => 'info', message => "Connected to $host successfully." );

#log into $host as $user
$scp->login($user) or die $scp->{errstr};

#write "connected to $host" to $file
$logfile->log( level => 'info', message => "Logged into $host successfully." );

#notify user of changing working directory to $remotedir
print "Chaging working directory to $remotedir\n";

#change working directory to $remotedir
$scp->cwd($remotedir) or die $scp->{errstr};

#Write Changed working directory (CWD) to $remotedir
$logfile->log( level => 'info', message => "CWD to $remotedir successfully." );

#display file size of $file
$scp->size($file) or die $scp->{errstr};

#notify user scp of $file has started
print "SCPing $remotedir$file from $host ...\n";

#scp $file from $host
$scp->get($file) or die $scp->{errstr};

#notify user scp of $file from $host was successful
print "$remotedir$file copied from $host successfully!\n";
{% endcodeblock %}

The Perl script basically asks the user what's the name of the file they want to print, reads in the file (; delimited in this case), outputs a postscript file.

Obviously you will have to make some changes in order to get these scripts to work in YOUR environment!

__Note:__ This is for Avery labels with Avery code 5961.  Please review  PostScript::MailLabels's documentation on CPAN to see if the module supports your particular labels or not.  You will also probably have to tweak the  "labelsetup" and "definelabel" parts to fit your needs.  Also note that the file this script reads is in the format of name;strete1;street2;city;st;zip$ semicolon delimited with a trailing $.  You will have to tweak the regex if your file is in a differet format.

__Disclaimer:  This blog entry comes with NO expressed warranty, guarantee, support, or maintenance of any kind!  Use at your own risk!__

Good luck and happy printing!
