#!/usr/bin/perl -wT

use strict;

use lib '/home/warbler/Warbler/lib';
use lib '/home/warbler/Warbler/lib/CPAN';

use Config::Config;
use Cache::Memcached::libmemcached;

# http://grebe.soupmode.com/291/textile-test-post-19nov2014-a

my $post_id = 291;

my $port        = Config::get_value_for("memcached_port");
my $domain_name = Config::get_value_for("domain_name");

my $key         = $domain_name . "-" . $post_id; 

my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );

my $val = $memd->delete($key);

print $val . "\n";
