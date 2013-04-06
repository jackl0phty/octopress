---
layout: post
#title: "net-hulu-perl-module-on-cpan"
title: "Net::Hulu Perl Module on CPAN"
date: 2013-01-18 21:48
author: Gerald L. Hevener Jr., M.S.
comments: true
categories: 
---
I wrote a Perl CPAN module Net::Hulu a while back.  You can install it like so:
<pre><code>
perl -MCPAN -e 'install Net::Hulu' 
</code></pre>

Net::Hulu provides methods to download all XML-formatted RSS feeds provided by hulu.com and return a data structure to the user containing the Data from the RSS feeds.

The following methods will download RSS feeds from hulu.com to directory where Hulu.pm is installed.

Method download_recent_videos_xml will download RSS feed for recent videos.

Method download_recent_shows_xml will download RSS feed for recent shows.

Method download_recent_movies_xml will download RSS feed for recent movies.

Method download_highest_rated_videos_xml will download RSS feed for highest rated videos.

Method download_popular_videos_today_xml will download RSS feed for today's popular videos.

Method download_popular_videos_this_week_xml will download RSS feed for this week's popular videos.

Method download_popular_videos_all_time_xml will download RSS feed for most popular videos of all time.

Method download_soon_to_expire_videos_xml will download RSS feed for soon to expire videos.

Method download_recent_blog_postings_xml will download RSS feed for recent blog postings to hulu.com.

The following methods will process all RSS feeds provided by hulu.com.

Method get_recent_videos returns a list of recently added videos to the user.

Method get_recent_shows returns a list of recently added shows to the user.

Method get_recent_movies returns a list of recently added movies to the user.

Method get_highest_rated_videos returns a list of highest rated videos to the user.

Method get_popular_videos_today returns a list of most popular videos today to the user.

Method get_popular_videos_this_week returns a list of most popular videos this week to the user.

Nethod get_popular_videos_all_time returns a list of most popular videos of all time to the user.

Method get_soon_to_expire_videos returns a list of soon to expire videos to the user.

Method get_recent_blog_postings returns recent blog postings for hulu.com to the user.

For detailed information on the Perl Module Net::Hulu, please visit the project's home page on CPAN at http://search.cpan.org/~jlophty/Net-Hulu-0.02/lib/Net/Hulu.pm.

<pre><code>
h2xs -b 5.6.0 -XA -n Net::Hulu
</code></pre>

This will remove all autoload and XS portions of the module, adding backwards compatibility with Perl versions >= 5.6.0, and making it a 'Pure Perl' implementation.

Disclaimer:  This blog entry comes with NO expressed warranty, guarantee, support, or maintenance of any kind.  Use at your own risk!  
