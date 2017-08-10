#!/usr/bin/perl -wT

use strict;
use warnings;
use diagnostics;

use LWP::Simple;
use JSON::PP;
use Data::Dumper;

my $num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: get-thread-post.pl postid\n";
    exit;
}

my $id = $ARGV[0];
my $db_url = 'http://127.0.0.1:5984/warblerdvlp1/' . $id;

my $json = get($db_url);

my $hash_ref = decode_json $json;

# print Dumper $hash_ref;

my $more_text = "";
if ( $hash_ref->{more_text_exists} ) {
    $more_text = " <a href=\"$hash_ref->{source_url}\">more &gt;&gt;</a>";
} 

my $html_output; 

if ( $hash_ref->{title} and $hash_ref->{html_title_tag_text} and $hash_ref->{content} ) {

    if ( $hash_ref->{content} =~ m|^\Q$hash_ref->{title}| ) {
        $hash_ref->{content} =~ s|^\Q$hash_ref->{title}||; 
        $html_output .= "<strong>$hash_ref->{title}</strong> - ";
    } elsif ( $hash_ref->{content} =~ m|^\Q$hash_ref->{html_title_tag_text}| ) {
        $hash_ref->{content} =~ s|^\Q$hash_ref->{html_title_tag_text}||; 
        $html_output .= "<strong>$hash_ref->{title}</strong> - ";
    } else {
        $html_output .= "<strong>$hash_ref->{title}</strong> - ";
    }

} elsif ( $hash_ref->{title} ) {
    $html_output .= "<strong>$hash_ref->{title}</strong> - ";
}

if ( length($hash_ref->{content}) > 0 ) { 
    $html_output .= "$hash_ref->{content} $more_text <br />";
}

$html_output .= "<small> - <a href=\"$hash_ref->{source_url}\">$hash_ref->{author_domain_name}</a></small>";

$html_output .= "<small> - $hash_ref->{display_date_time}</small>";

$html_output .= "<small> - <a href=\"/$hash_ref->{_id}/$hash_ref->{slug}\">0 comments</a></small>";

print $html_output . "\n";

print "\n title = " . $hash_ref->{title} . "\n\n" if $hash_ref->{title};
print "\n html title tag text = " . $hash_ref->{html_title_tag_text} . "\n\n";
print "\n content = " . $hash_ref->{content} . "\n\n";

