#!/usr/bin/perl -wT

use strict;

use lib '/home/warbler/Warbler/lib';

use App::Config;
use Cache::Memcached::libmemcached;

my $post_id = 'test-post-17feb2015-a';

my $port        = Config::get_value_for("memcached_port");
my $domain_name = Config::get_value_for("domain_name");

my $key         = $domain_name . "-" . $post_id; 

my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );

my $val = $memd->get($key);

if ( $val ) {
    print "exists: ". $val . "\n";
} else {
    print "post id $post_id does not exist\n";
}
