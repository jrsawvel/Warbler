#!/usr/bin/perl -wT

use CouchDB::Client;
use Data::Dumper;


my $db = "warblerdvlp1";

my $view_js;

my $c = CouchDB::Client->new();
$c->testConnection or die "The server cannot be reached";

$rc = $c->req('GET', $db . '/_design/views');

my $perl_hash = $rc->{'json'};



# homepage stream of posts listed by updated date
my $view_js =  <<VIEWJS1;
function(doc) {
    if( doc.type === 'threadpost' && doc.post_status === 'public' ) {
        emit(doc.last_post_date, doc);
    }
}
VIEWJS1
$perl_hash->{'views'}->{'warblerstream'}->{'map'} = $view_js;




##############################################


# update the view doc entry
$rc = $c->req('PUT', $db . '/_design/views', $perl_hash);
print Dumper $rc;

