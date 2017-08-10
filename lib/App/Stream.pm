package Stream;

use strict;
use warnings;
use diagnostics;

use LWP::Simple;
use JSON::PP;
use App::Format;


sub show_stream {
    my $tmp_hash    = shift;
    my $creation_type = shift; # if equals "private", then called from Post.pm and done so to cache home page.

    my $db_name   = Config::get_value_for("database_name");
    my $db_server = Config::get_value_for("database_server");
    my $db_port   = Config::get_value_for("database_port");

    if ( !$creation_type ) {
        $creation_type = "public";
    }
    
    my $page_num = 1;
    if ( Utils::is_numeric($tmp_hash->{one}) ) {
        $page_num = $tmp_hash->{one};
    }

    my $max_entries = Config::get_value_for("max_entries_on_page");

    my $skip_count = ($max_entries * $page_num) - $max_entries;

    my $db_url = $db_server . ':' . $db_port . '/' . $db_name; 
    $db_url .= '/_design/views/_view/warblerstream/?descending=true&limit='; 
    $db_url .= ($max_entries + 1) . '&skip=' . $skip_count;

    my $json = get($db_url);

    my $hr = decode_json $json;

    my $stream = $hr->{'rows'};

    my $next_link_bool = 0;
    my $len = @$stream;
    if ( $len > $max_entries ) {
        $next_link_bool = 1;
    }

    my @posts;

    my $ctr=0;
    foreach my $post_ref ( @$stream ) {
        # delete($post_ref->{'value'}->{'tags'});
        my $output_ref->{'html'} = Format::create_html_output($post_ref->{'value'}, "stream");
        push(@posts, $output_ref);
        last if ++$ctr == $max_entries;
    }

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

    if ( $creation_type ne "private" ) {
        my $cache_it = 1;
        if ( $page_num > 1 ) {
            $cache_it = 0;
        }
        $t->display_page("Stream of Posts", $cache_it, "homepage");
        # $t->display_page("Stream of Posts");
    } else {
        return $t->create_html("Stream of Posts");
    }

}

1;

