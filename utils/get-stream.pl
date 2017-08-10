#!/usr/bin/perl -wT

use strict;
use warnings;
use diagnostics;

$|++;

use lib '../lib';
use App::Page;
use App::Config;

use LWP::Simple;
use JSON::PP;
use Data::Dumper;

my $page_num = 2;
my $max_entries = 15;
my $skip_count = ($max_entries * $page_num) - $max_entries;
my $db_url = 'http://127.0.0.1:5984/warblerdvlp1/_design/views/_view/warblerstream/?descending=true&limit=' . ($max_entries + 1) . '&skip=' . $skip_count;

my $json = get($db_url);

my $hr = decode_json $json;

my $stream = $hr->{'rows'};

# print Dumper $stream;

my $next_link_bool = 0;
my $len = @$stream;
if ( $len > $max_entries ) {
    $next_link_bool = 1;
}


my @posts;

my $ctr=0;
foreach my $post_ref ( @$stream ) {
    # delete($post_ref->{'value'}->{'tags'});
    my $output_ref->{'html'} = create_html_output($post_ref->{'value'});
    push(@posts, $output_ref);
    last if ++$ctr == $max_entries;
}


# print Dumper @posts;

my $t = Page->new("stream");

$t->set_template_loop_data("stream_loop", \@posts);

    if ( $page_num == 1 ) {
        $t->set_template_variable("not_page_one", 0);
    } else {
        $t->set_template_variable("not_page_one", 1);
    }

    if ( $len >= $max_entries && $next_link_bool ) {
        $t->set_template_variable("not_last_page", 1);
    } else {
        $t->set_template_variable("not_last_page", 0);
    }
    my $previous_page_num = $page_num - 1;
    my $next_page_num = $page_num + 1;
    my $next_page_url = "/stream/$next_page_num";
    my $previous_page_url = "/stream/$previous_page_num";
    $t->set_template_variable("next_page_url", $next_page_url);
    $t->set_template_variable("previous_page_url", $previous_page_url);

print $t->create_html("Stream of Posts");





#############################################

sub create_html_output {
    my $hash_ref = shift;

my $more_text = "";
if ( $hash_ref->{more_text_exists} ) {
    $more_text = " <a href=\"$hash_ref->{source_url}\">more&gt;&gt;</a>";
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

$html_output .= "<small> - <a href=\"/$hash_ref->{id}/$hash_ref->{slug}\">Comments: $hash_ref->{comment_count}</a></small>";

return $html_output;

}
