#!/usr/bin/perl -wT

use strict;

use lib '/home/warbler/Warbler/lib';

use App::Config;
use Cache::Memcached::libmemcached;

my $port        = Config::get_value_for("memcached_port");

my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );

my $val = $memd->flush_all;

print $val . "\n";
