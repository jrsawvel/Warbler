#!/usr/bin/perl -wT

use CouchDB::Client;
use Data::Dumper;

my $rc;

    my $db = "warblerdvlp1";

    my $keyword = "qRhAKXBrxftAUw699VCOQ"; # thread start post id

    my $c = CouchDB::Client->new();
    $c->testConnection or die "no db connect";

    my $couchdb_uri = $db . "/_design/views/_view/warblercomments?descending=true";
    $couchdb_uri = $couchdb_uri . "&startkey=[\"$keyword\", {}]&endkey=[\"$keyword\"]";


    $rc = $c->req('GET', $couchdb_uri);

    my $stream = $rc->{'json'}->{'rows'};

    print Dumper $stream; # display the comments


#    my @r = reverse $stream;
    print "\n\n\n\n\n";
#    print Dumper \@r;


    my @reversed = rev(@$stream);

    print Dumper \@reversed;



sub rev
{
    my @r;
    push @r, pop @_ while @_;
    @r
}
