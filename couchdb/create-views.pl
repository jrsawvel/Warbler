#!/usr/bin/perl -wT

use JSON::PP;
use CouchDB::Client;
use Data::Dumper;


my $db = "warblerdvlp1";


my $views = <<VIEWS;
{
  "_id":"_design/views"
}
VIEWS

# convert json string into a perl hash
my $perl_hash = decode_json $views;


# homepage stream of posts listed by updated date
my $view_js =  <<VIEWJS1;
function(doc) {
    if( doc.type === 'threadpost' && doc.post_status === 'public' ) {
        emit(doc.last_post_date, doc);
    }
}
VIEWJS1
$perl_hash->{'views'}->{'warblerstream'}->{'map'} = $view_js;


# comments for a thread post id
$view_js =  <<VIEWJS2;
function(doc) {
    if( doc.type === 'comment' && doc.post_status === 'public' ) {
        emit( [ doc.parent_id, doc.created_at ], doc );   
    }
}
VIEWJS2
$perl_hash->{'views'}->{'warblercomments'}->{'map'} = $view_js;



# get doc for source_url
$view_js =  <<VIEWJS3;
function(doc) {
    if( doc.post_status === 'public' ) {
        emit(doc.source_url, doc);
    }
}
VIEWJS3
$perl_hash->{'views'}->{'warblersourceurl'}->{'map'} = $view_js;



# get doc for content signature hash
$view_js =  <<VIEWJS4;
function(doc) {
    if( doc.post_status === 'public' ) {
        emit(doc.content_sig, doc);
    }
}
VIEWJS4
$perl_hash->{'views'}->{'warblercontentsig'}->{'map'} = $view_js;



my $c = CouchDB::Client->new();
$c->testConnection or die "The server cannot be reached";

# create the view doc entry
my $rc = $c->req('POST', $db, $perl_hash);
print Dumper $rc;

print "\n\n\n";

$rc = $c->req('GET', $db . '/_design/views');
print Dumper $rc;
print "\n";

