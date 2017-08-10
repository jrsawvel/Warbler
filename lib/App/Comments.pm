package Comments;

use strict;
use warnings;
use diagnostics;

use LWP::Simple;
use JSON::PP;
use App::Format;


sub get_comments {
    my $thread_id = shift;

    my $rc;

    my $db_name   = Config::get_value_for("database_name");
    my $db_server = Config::get_value_for("database_server");
    my $db_port   = Config::get_value_for("database_port");

    my $db_url = $db_server . ':' . $db_port . '/' . $db_name; 
    $db_url .= "/_design/views/_view/warblercomments?descending=true";
    $db_url .= "&startkey=[\"$thread_id\", {}]&endkey=[\"$thread_id\"]";

    my $json = get($db_url);

    my $hr = decode_json $json;

    my $stream = $hr->{'rows'};

    my @reversed = rev(@$stream);

    my @posts;

    foreach my $post_ref ( @reversed ) {
        my $output_ref->{'comment_html'} = Format::create_html_output($post_ref->{'value'}, "comment");
        push(@posts, $output_ref);
    }

    return @posts;
}


# http://www.perlmonks.org/?node_id=41167
sub rev
{
    my @r;
    push @r, pop @_ while @_;
    @r
}


sub show_new_comment_form {
    my $tmp_hash = shift;

    my $thread_id = $tmp_hash->{one};

    if ( !$thread_id ) {
        Page->report_error("user", "Cannot add comment.", "Thread ID is missing.");
    }

    my $t = Page->new("newcommentform");

    my $target_url = Config::get_value_for("home_page") . '/thread/' . $thread_id;

    $t->set_template_variable("threadid", $thread_id);

    $t->set_template_variable("target_url", $target_url);

    $t->display_page("New Comment Form");
}


1;
