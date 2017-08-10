package Webmention;

use strict;
use warnings;
use diagnostics;

use CGI qw(:standard);
use Time::Local;
use JSON::PP;
use LWP::UserAgent;
use LWP::Simple;
use HTTP::Request;
use JSON::PP;
use Cache::Memcached::libmemcached;
use App::SourceURI;
use App::Thread;
use App::Stream;


sub post_webmention {

    my $q = new CGI;

    my $request_method = $q->request_method();

    my $sb         = undef; 
    my $source_url = undef;
    my $target_url = undef;
    my $web_form = 1;

    $source_url = $q->param("source"); 
    $target_url = $q->param("target"); 
    $sb         = $q->param("sb");

    if ( !$sb or length($sb) < 1 ) {
        $web_form = 0;
    }

    if ( website_throttle() ) {
        do_error($web_form, "Website throttle limit reached.", "Try your submission again in a minute or two.");
    }

    my $source_content = undef;
    my $target_content = undef;

    my $ua = LWP::UserAgent->new;
    my $res = undef;

    $ua->agent('Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.125 Safari/537.36');

    if ( $request_method ne "POST" ) {
        do_error($web_form, "Invalid request or action. Only POST is accepted.", "Request method = $request_method.");
    }

    if ( !defined($source_url) || length($source_url) < 1 )  { 
        do_error($web_form, "source_not_found", "The source URI does not exist.");
    } 
     
    if ( !defined($target_url) || length($target_url) < 1 )  { 
        do_error($web_form, "target_not_found", "The target URI does not exist.");
    } 

    $res = $ua->get( $source_url );
    if ( $res->code > 299 ) {
        do_error($web_form, "source_not_found", "The source URI does not exist.");
    }
    $source_content = $res->content;

    $res = $ua->get( $target_url );
    if ( $res->code > 299 ) {
        do_error($web_form, "target_not_found", "The target URI does not exist.");
    }
    $target_content = $res->content;

# debug - comment out for now
#    if ( ($source_content !~ m|$target_url|is) ) {
#        do_error($web_form, "no_link_found", "The source URI does not contain a link to the target URI.");
#    } 

    # if reached this point, then the post can be added to database.

    my $hash_ref = SourceURI::process_source_uri($source_url, $target_url, $source_content);

    if ( exists($hash_ref->{error}) ) {
        do_error($web_form, $hash_ref->{error}, $hash_ref->{error_description});
    }

    if ( author_domain_name_throttle($hash_ref->{author_domain_name}) ) {
        do_error($web_form, "Throttle limit reached for $hash_ref->{author_domain_name}.", "Try your submission again in a few minutes.");
    }


    my $json = encode_json $hash_ref;

    my $db_name   = Config::get_value_for("database_name");
    my $db_server = Config::get_value_for("database_server");
    my $db_port   = Config::get_value_for("database_port");

    my $db_url = $db_server . ':' . $db_port . '/' . $db_name; 

    my $parent_id_hash_ref = undef;
    if ( exists($hash_ref->{parent_id}) ) {
        my $tmp_parent_id_json = get($db_url . '/' . $hash_ref->{parent_id});
        $parent_id_hash_ref = decode_json $tmp_parent_id_json;
        if ( exists($parent_id_hash_ref->{error}) and $parent_id_hash_ref->{reason} eq "missing" ) {
            do_error($web_form, "not_found", "Could not add comment because thread ID does not exist.");
        }
    }

    my $req = HTTP::Request->new( 'POST', $db_url);
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( $json );

    my $lwp = LWP::UserAgent->new;
    my $response = $lwp->request( $req );
    my @rc = split(/ /, $response->status_line);
    my $rc = $rc[0];

    my $returned_json_hash_ref = decode_json $response->content;

    if ( $rc >= 200 and $rc < 300 ) {

        my $cache_post_id = $returned_json_hash_ref->{id};

        if ( exists($hash_ref->{parent_id}) ) {
            $parent_id_hash_ref->{comment_count}  = $parent_id_hash_ref->{comment_count} + 1;
            $parent_id_hash_ref->{last_post_date} = $hash_ref->{created_at};
            $parent_id_hash_ref->{last_post_id}   = $returned_json_hash_ref->{id};
            if ( !update_thread_post($parent_id_hash_ref) ) {
                do_error($web_form, "Failure", "Could not update parent ID.");
            }
           
            $cache_post_id = $hash_ref->{parent_id};
        }

        if ( Config::get_value_for("write_html_to_memcached") ) {
            _write_html_to_memcached($cache_post_id);
        }   

        update_website_throttle();
        update_author_throttle($hash_ref->{author_domain_name});

 
        if ( $web_form ) {
            my $home_page = Config::get_value_for("home_page");
            if ( exists($hash_ref->{parent_id}) ) {
                print $q->redirect( -url => $home_page . '/thread/' . $hash_ref->{parent_id} . '#' . $returned_json_hash_ref->{id});
#                Page->success("Adding a comment.", "Success", "Webmention comment was added.");
            } else {
                print $q->redirect( -url => $home_page . '/thread/' . $returned_json_hash_ref->{id});
                exit;
#                Page->success("Starting a new thread post.", "Success", "Webmention was added to start a new thread.");
            }
        } else {
            my $json = '{"result": "WebMention was successful"}';
            print header('application/json', '200 OK');
            print $json;
            exit;
        }
    } elsif ( $rc >= 400 and $rc < 500 ) {
        do_error($web_form, "Failure.", "Could not add webmention");
    } 


}


sub do_error {
    my $web_form = shift;
    my $error = shift;
    my $error_description = shift;

    if ( $web_form ) {
        Page->report_error("user", $error, $error_description);
    } else {
        __report_error("400", $error, $error_description);
    }
}

sub __report_error {
    my $error_code = shift;
    my $error = shift;
    my $description = shift;

        my $json = <<JSONMSG;
{"error": "$error","error_description": "$description"}
JSONMSG

        print header('application/json', "$error_code Bad Request");
        print $json;
        exit;
}


sub update_thread_post {
    my $hash_ref = shift;

    my $db_name   = Config::get_value_for("database_name");
    my $db_server = Config::get_value_for("database_server");
    my $db_port   = Config::get_value_for("database_port");

    my $db_url = $db_server . ':' . $db_port . '/' . $db_name . '/' . $hash_ref->{_id};

    my $json = encode_json $hash_ref;

    my $req = HTTP::Request->new( 'PUT', $db_url);
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( $json );

    my $lwp = LWP::UserAgent->new;
    my $response = $lwp->request( $req );
    my @rc = split(/ /, $response->status_line);
    my $rc = $rc[0];

    my $returned_json_hash_ref = decode_json $response->content;

    if ( $rc >= 200 and $rc < 300 ) {
        return 1;
    } elsif ( $rc >= 400 and $rc < 500 ) {
        return 0; 
    } 
}

sub _write_html_to_memcached {
    my $id = shift;

    my $tmp_hash;
    $tmp_hash->{one} = $id;

    my $html = Thread::show_thread($tmp_hash, "private");

    $html .= "\n<!-- memcached -->\n";

    my $port         =  Config::get_value_for("memcached_port");
    my $domain_name  =  Config::get_value_for("domain_name");
    my $key          =  $domain_name . "-" . $id;
    my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );
    my $rc = $memd->set($key, $html);


    my $tmp_hash;
    $tmp_hash->{one}=1;
    $html = Stream::show_stream($tmp_hash, "private");
    $html .= "\n<!-- memcached -->\n";
    $key =  $domain_name . "-homepage";
    $rc = $memd->set($key, $html);
}

sub website_throttle {

    # check to see how long ago a post was made.

    my $current_epoch_seconds = time();

    my $port         =  Config::get_value_for("memcached_port");
    my $domain_name  =  Config::get_value_for("domain_name");
    my $key          =  $domain_name . "-website-throttle";
    my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );
    my $val = $memd->get($key);

    if ( $val ) {
        if ( ( $current_epoch_seconds - $val )  <  Config::get_value_for("website_throttle_interval") ) {
            return 1;
        }
    }

    return 0;
}

sub update_website_throttle {

    my $current_epoch_seconds = time();

    my $port         =  Config::get_value_for("memcached_port");
    my $domain_name  =  Config::get_value_for("domain_name");
    my $key          =  $domain_name . "-website-throttle";
    my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );
    my $rc = $memd->set($key, $current_epoch_seconds);

}

sub author_domain_name_throttle {
    my $author_domain_name = shift;

    # check to see how long ago a post was made.

    my $current_epoch_seconds = time();

    my $port         =  Config::get_value_for("memcached_port");
    my $domain_name  =  Config::get_value_for("domain_name");
    my $key          =  $domain_name . "-" . $author_domain_name . "-throttle";
    my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );
    my $val = $memd->get($key);

    if ( $val ) {
        if ( ( $current_epoch_seconds - $val )  <  Config::get_value_for("author_throttle_interval") ) {
            return 1;
        }
    }

    return 0;
}

sub update_author_throttle {
    my $author_domain_name = shift;

    my $current_epoch_seconds = time();

    my $port         =  Config::get_value_for("memcached_port");
    my $domain_name  =  Config::get_value_for("domain_name");
    my $key          =  $domain_name . "-" . $author_domain_name . "-throttle";
    my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );
    my $rc = $memd->set($key, $current_epoch_seconds);

}

1;


__END__

https://webmention.net/

<form action="/webmention" method="post">
<input size=31 type=text name="source"> 
<input type="hidden" name="target" value="http://warbler.soupmode.com">
<input class="submitbutton" type=submit name=sb value="Submit">
</form>


curl -i -d "source=http://jothut.com/cgi-bin/junco.pl/blogpost/75157/Reply-to-Cawrs-post-about-publishers-and-UX&target=http://wren.soupmode.com/in-2016-digital-publishers-are-finally-concerned-about-ux.html" http://warbler.soupmode.com/webmention

