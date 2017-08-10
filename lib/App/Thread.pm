package Thread;

use strict;
use warnings;
use diagnostics;

use LWP::Simple;
use JSON::PP;
use App::Format;
use App::Comments;


sub show_thread {
    my $tmp_hash    = shift;
    my $creation_type = shift;

    my $db_name   = Config::get_value_for("database_name");
    my $db_server = Config::get_value_for("database_server");
    my $db_port   = Config::get_value_for("database_port");

    my $thread_id = $tmp_hash->{one};
    
    if ( !$thread_id ) {
        Page->report_error("user", "Cannot retrieve thread.", "Thread post ID was missing.");
    }    

    my $db_url = $db_server . ':' . $db_port . '/' . $db_name . '/' . $thread_id; 

    my $json = get($db_url);

    my $hash_ref = decode_json $json;

    my $html_output = Format::create_html_output($hash_ref, "thread");

    my $t = Page->new("thread");
    
    $t->set_template_variable("html", $html_output);
    $t->set_template_variable("threadid", $thread_id);

    my $target_url = Config::get_value_for("home_page") . '/thread/' . $thread_id; 

    $t->set_template_variable("target_url", $target_url);

    my @comments = Comments::get_comments($thread_id);

    $t->set_template_loop_data("comment_loop", \@comments);

    if ( $creation_type and $creation_type eq "private" ) {
        return $t->create_html("Thread - $hash_ref->{slug}");
    } else {
        my $cache_it = 1;
        $t->display_page("Thread - $hash_ref->{slug}", $cache_it, $thread_id);
        # $t->display_page("Thread - $hash_ref->{slug}");
    }

}

sub show_new_thread_post_form {
    my $t = Page->new("newthreadpostform");

    $t->set_template_variable("thread_post_target_uri", Config::get_value_for("thread_post_target_uri"));

    $t->display_page("New Thread Post Form");
}


1;
