#!/usr/bin/perl -wT

use strict;
use warnings;
use diagnostics;

use LWP::Simple;
use CouchDB::Client;
use LWP::UserAgent;
use HTML::Entities;
use Encode;
use HTML::TokeParser;
use HTTP::Request;
use JSON::PP;
use Data::Dumper;
use Digest::MD5;


my $IS_NOTE = 0;

my $MORE_TEXT = 0;


main();



sub main {


my $db                 =   "warblerdvlp1";
my $target_url         =   'http://warbler.soupmode.com/index.html';
my $article_title      =   undef;
my $post_content       =   undef;



my $num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: get-content.pl url\n";
    exit;
}
my $source_url = $ARGV[0];



my $web_page = get_web_page($source_url);
if ( !$web_page or length($web_page) < 1 ) {
    die "could not retrieve web page for $source_url";
}
$web_page = Encode::decode_utf8($web_page);



my $author_domain_name = get_author_domain_name($source_url);



# new for 07aug2017
### has source url been submitted already?
if ( source_url_exists($source_url) ) {
    die "$source_url has been submitted already.";
}


# search source_web_page for the target_url
# debug if ( ($web_page !~ m|$target_url[\D]|) ) {
#    die "no_link_found. The source URI does not contain a link to the target URI.";
#} 



my $html_title_tag_text = get_html_title_tag_text($web_page);


$article_title = get_article_title_from_open_graph($web_page);



if ( !$article_title ) {
    $article_title = get_article_title_from_microformats($web_page);
}  


$post_content = get_post_content_from_open_graph($web_page);
if ( $post_content ) {
    $MORE_TEXT = 1;
}

if ( !$post_content ) {
    $post_content       = get_content_from_microformats($web_page); 
}

if ( !$post_content or !$article_title ) {
    my $hash_ref = get_content_from_article_tag($web_page);
    $post_content  = $hash_ref->{content} if !$post_content;
    $article_title = $hash_ref->{title} if !$article_title;
}


if ( !$post_content or !$article_title ) {
    my $hash_ref = get_content_from_main_tag($web_page);
    $post_content  = $hash_ref->{content} if !$post_content;
    $article_title = $hash_ref->{title} if !$article_title;
}


if ( !$post_content or !$article_title ) {
    my $hash_ref = get_content_from_body_tag($web_page);
    $post_content  = $hash_ref->{content} if !$post_content;
    $article_title = $hash_ref->{title} if !$article_title;

    if ( !$article_title ) {
        $article_title = $html_title_tag_text;
    }
}






$post_content = trim_spaces($post_content);
$post_content = remove_html($post_content);
$post_content = remove_newline($post_content);
$post_content = HTML::Entities::encode($post_content,'^\n^\r\x20-\x25\x27-\x7e');

while ( $post_content =~ m|  |gs ) {
    $post_content =~ s|  | |gs;
}

if ( length($post_content) > 300 ) {
    $post_content = substr $post_content, 0, 300;
    $post_content .= " ...";
    $MORE_TEXT = 1;
}



$article_title = trim_spaces($article_title);
$article_title = remove_html($article_title);
$article_title = remove_newline($article_title);
$article_title = HTML::Entities::encode($article_title, '^\n^\r\x20-\x25\x27-\x7e');




if ( $IS_NOTE ) {
    $article_title = undef;
}    



my $dt           = create_datetime_stamp();
my $formatted_dt = format_date_time($dt);



my $md5 = Digest::MD5->new;
$md5->add(otp_encrypt_decrypt($post_content, $dt, "enc"), $author_domain_name, $formatted_dt);
my $post_digest = $md5->b64digest;
$post_digest =~ s|[^\w]+||g;


# new 07aug2017
my $tmp_str = " ";

if ( !$post_content ) {
    $tmp_str .= " ";
} else {
    $tmp_str .= $post_content;
}

if ( !$article_title ) {
    $tmp_str .= " ";
} else {
    $tmp_str .= $article_title;
}

if ( !$html_title_tag_text ) {
    $tmp_str .= " ";
} else {
    $tmp_str .= $html_title_tag_text;
}

$md5 = Digest::MD5->new;
$md5->add(otp_encrypt_decrypt($tmp_str, "warblerdvlp1",  "enc"));
my $content_sig = $md5->b64digest;
$content_sig =~ s|[^\w]+||g;

if ( content_sig_exists($content_sig, $author_domain_name) ) {
    die "based upon content_sig, $source_url has been submitted already.";
}
# end new 07aug2017


my $slug = undef;
if ( $article_title ) {
    $slug = clean_title($article_title);
} elsif ( $html_title_tag_text ) {
    $slug = clean_title($html_title_tag_text);
} else {
    $slug = clean_title($formatted_dt);
}



my $cdb_hash = {
        '_id'                   =>  $post_digest,
        'content_sig'           =>  $content_sig,
        'type'                  =>  'threadpost',
        'title'                 =>  $article_title,
        'html_title_tag_text'   =>  $html_title_tag_text,
        'slug'                  =>  $slug,
        'content'               =>  $post_content,
        'source_url'            =>  $source_url,
        'more_text_exists'      =>  $MORE_TEXT,
        'author_domain_name'    =>  $author_domain_name,
        'created_at'            =>  $dt,
        'comment_count'         =>  0,
        'last_post_date'        =>  $dt,
        'post_status'           =>  'public',
        'display_date_time'     =>  $formatted_dt
    };


    my $uri = 'http://127.0.0.1:5984/' . $db;

    my $json = encode_json $cdb_hash;

    my $req = HTTP::Request->new( 'POST', $uri );
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( $json );

    my $lwp = LWP::UserAgent->new;
    my $response = $lwp->request( $req );
    my @rc = split(/ /, $response->status_line);
    my $rc = $rc[0];

    my $returned_json_hash_ref = decode_json $response->content;

    if ( $rc >= 200 and $rc < 300 ) {
        print "post successfully created.\n";
        print Dumper $returned_json_hash_ref;        
    } elsif ( $rc >= 400 and $rc < 500 ) {
        print Dumper $returned_json_hash_ref;        
    } 

} # end main


sub remove_html {
    my $str = shift;
    # remove ALL html
    $str =~ s/<([^>])+>|&([^;])+;//gsx;
    return $str;
}

sub remove_newline {
    my $str = shift;
    $str =~ s/\n/ /gs;
    $str =~ s/\r/ /gs;
    return $str;
}

sub trim_spaces {
    my $str = shift;
    if ( !defined($str) ) {
        return "";
    }
    # remove leading spaces.   
    $str  =~ s/^\s+//;
    # remove trailing spaces.
    $str  =~ s/\s+$//;
    return $str;
}

sub create_datetime_stamp {

    # creates string for DATETIME field in database as
    # YYYY/MM/DD HH:MM:SS    (24 hour time)
    # Date and time is GMT not local.

    my $epochsecs = time();
    my ($sec, $min, $hr, $mday, $mon, $yr)  = (gmtime($epochsecs))[0,1,2,3,4,5];
    my $datetime = sprintf "%04d/%02d/%02d %02d:%02d:%02d", 2000 + $yr-100, $mon+1, $mday, $hr, $min, $sec;
    return $datetime;
}

sub format_date_time {
    my $orig_dt = shift;

    my @tmp_array = split(/ /, $orig_dt);

    my $date = $tmp_array[0];
    my $time = $tmp_array[1];

    my @date_array = split(/\//, $date);

    my %hash = ();
 
    my @short_month_names = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    
    my $formatted_dt = sprintf "%s %d, %d %s Z", $short_month_names[$date_array[1]-1], $date_array[2], $date_array[0], $time;

    return $formatted_dt;
}




sub get_webmention {

    my $webmention = <<HTMLPOST;
<html lang="en">
<head>
    <title>Test Post 13Jul2017 | Wren</title>
    <meta charset="UTF-8" /> 
    <meta name="generator"             content="Wren v1.0" />
    <meta name="author"                content="cawr" />
</head>
<body>
<article class="h-entry">
  <header>
    <h1 class="p-name">Test Post 13Jul2017</h1> 
  </header>
  <div class="e-content">
    <p><span class="p-summary">Wanting some test HTML to help test my new webmention-based message board idea. This will be the opening, summary paragraph.</span></p>
    <p>This is another paragraph.</p>
    <p>And a third paragraph.</p>
    <p>thread starter post to <a href="http://warbler.soupmode.com/index.html">warbler</a>.</p>
  </div> 
  <footer style="display:none;">
    <p>
      <a class="p-author h-card"  href="/about">cawr</a> - 
      <a class="u-url" href="">#</a>
    </p>
  </footer>
</article>
</body>
</html>
HTMLPOST

    return $webmention;

}

sub get_webmention_2 {

    my $webmention = <<HTMLPOST;
<html lang="en">
<head>
    <title>Test Post 13Jul2017 | Wren</title>
    <meta charset="UTF-8" /> 
    <meta name="generator"             content="Wren v1.0" />
    <meta name="author"                content="cawr" />
</head>
<body>
<article class="h-entry">
  <header>
    <h1 class="p-name">Test Post 13Jul2017</h1> 
  </header>
  <div class="e-content">
    <p><span class="p-summary">Wanting some test HTML to help test my new webmention-based message board idea. This will be the opening, summary paragraph.</span></p>
    <p>This is another paragraph.</p>
    <p>And a third paragraph.</p>
    <p>thread starter post to <a href="http://warbler.soupmode.com/index.html">warbler</a>.</p>
    <p>
    Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.
    </p>
    <p>
    It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.
    </p>
    <p>
    It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
    </p>
  </div> 
  <footer style="display:none;">
    <p>
      <a class="p-author h-card"  href="/about">cawr</a> - 
      <a class="u-url" href="">#</a>
    </p>
  </footer>
</article>
</body>
</html>
HTMLPOST

    return $webmention;

}

sub get_webmention_3 {

    my $webmention = <<HTMLPOST;
<html lang="en">
<head>
    <title>Test Post 13Jul2017 | Wren</title>
    <meta charset="UTF-8" /> 
    <meta name="generator"             content="Wren v1.0" />
</head>
<body>
    <h1>Test Post 13Jul2017</h1> 
    <p><span class="p-summary">Wanting some test HTML to help test my new webmention-based message board idea. This will be the opening, summary paragraph.</span></p>
    <p>This is another paragraph.</p>
    <p>And a third paragraph.</p>
    <p>thread starter post to <a href="http://warbler.soupmode.com/index.html">warbler</a>.</p>
    <p>
    Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.
    </p>
    <p>
    It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.
    </p>
    <p>
    It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
    </p>
</body>
</html>
HTMLPOST

    return $webmention;

}


sub otp_encrypt_decrypt {

##     Otp v1.0
##     Last modified: March 2nd, 2000
##
##     Copyright (c) 2000 by Trans-Euro I.T Ltd
##     All Rights Reserved
##
##     E-Mail: tigger@marketrends.net
##
##	This module can be used to encrypt and decrypt
##	character strings. Using an xor operation.
##	As long as the same 'key' is used, the original
##	string can always be derived from its encryption.
##	The 'key' may be any length although keys longer
##	than the string to be encrypted are truncated.


    my $P1 = shift;
    my $K1 = shift;
    my $func = shift;


    if ( $func eq "dec" ) {
        $P1 =~ s/%([a-f0-9][a-f0-9])/chr( hex( $1 ) )/eig; 
    }

    my @_p = ();
    my @_k = ();
    my @_e = ();
    my $_l = "";
    my $_i = 0;
    my $_r = "";

    while ( length($K1) < length($P1) ) { $K1=$K1.$K1;}

    $K1=substr($K1,0,length($P1));

    @_p=split(//,$P1);
    @_k=split(//,$K1);

    foreach $_l (@_p) {
       $_e[$_i] = chr(ord($_l) ^ ord($_k[$_i]));
       $_i++;
                      }

    $_r = join '',@_e;

    if ( $func eq "enc" ) {
        $_r =~ s/([^a-z0-9_.!~*() -])/sprintf "%%%02X", ord($1)/eig;
    }

    return $_r;    
}



sub clean_title {
        my $str = shift;
        $str =~ s|[-]||g;
        $str =~ s|[ ]|-|g;
        $str =~ s|[:]|-|g;
        $str =~ s|--|-|g;
        # only use alphanumeric, underscore, and dash in friendly link url
        $str =~ s|[^\w-]+||g;
        return lc($str);
}

sub get_html_title_tag_text {
    my $c = shift;

    my $ptitle = HTML::TokeParser->new(\$c);

    my $title = undef;

    if ( $ptitle->get_tag('title') ) {
        $title = $ptitle->get_text('/title');
        $title = trim_spaces($title);
        $title = remove_html($title);
        $title = remove_newline($title);
        $title = HTML::Entities::encode($title, '^\n^\r\x20-\x25\x27-\x7e');
    }

    return $title;
}


sub get_web_page {
    my $url = shift;

    my $ua = LWP::UserAgent->new;

    $ua->agent('Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.125 Safari/537.36');

    my $res = $ua->get( $url );

    if ( $res->code > 299 ) {
        die "could not retrieve content for $url - code = " . $res->code . " - message = " . $res->message . "\n";
    }

    return $res->content;
}

sub get_author_domain_name {
    my $url = shift;

    $url =~ s!^https?://(?:www\.)?!!i;
    $url =~ s!/.*!!;
    $url =~ s/[\?\#\:].*//;

    return $url;
}


sub get_article_title_from_microformats {
    my $c = shift;

    my $title = undef;

    my $p = undef;

    if ( !$title ) {
        $p = HTML::TokeParser->new(\$c);
        while ( my $h1_tag = $p->get_tag('h1') ) {
            if ( $h1_tag->[1]{class} and $h1_tag->[1]{class} =~ m/p-name|entry-title/i ) {
                $title = $p->get_text('/h1');
                last;
            }
        }
    }

    if ( !$title ) {
        $p = HTML::TokeParser->new(\$c);
        while ( my $h2_tag = $p->get_tag('h2') ) {
            if ( $h2_tag->[1]{class} and $h2_tag->[1]{class} =~ m/p-name|entry-title/i ) {
                $title = $p->get_text('/h2');
                last;
            }
        }
    }

    if ( !$title ) {
        $p = HTML::TokeParser->new(\$c);
        while ( my $h3_tag = $p->get_tag('h3') ) {
            if ( $h3_tag->[1]{class} and $h3_tag->[1]{class} =~ m/p-name|entry-title/i ) {
                $title = $p->get_text('/h3');
                last;
            }
        } 
    }

    return $title;
}


sub get_content_from_microformats {
    my $c = shift;

    my $content = undef;

    my $p1 = HTML::TokeParser->new(\$c);
    my $p2 = HTML::TokeParser->new(\$c);
    my $p3 = HTML::TokeParser->new(\$c);
    my $p4 = HTML::TokeParser->new(\$c);
    my $p5 = HTML::TokeParser->new(\$c);
    my $p6 = HTML::TokeParser->new(\$c);
    my $p7 = HTML::TokeParser->new(\$c);

    if ( !$content ) {
        while ( my $tag = $p1->get_tag('span') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m/p-summary|entry-content/i ) {
                $content  = $p1->get_text('/span');
                $MORE_TEXT = 1 if $tag->[1]{class} =~ m|p-summary|;
                last;
            }
        }
    }

    if ( !$content ) {
        while ( my $tag = $p2->get_tag('p') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m/p-summary|entry-content/i ) {
                $content  = $p2->get_text('/p');
                $MORE_TEXT = 1 if $tag->[1]{class} =~ m|p-summary|;
                last;
            }
        }
    }

    if ( !$content ) {
        while ( my $tag = $p3->get_tag('section') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m/p-summary|entry-content/i ) {
                $content  = $p3->get_text('/section');
                $MORE_TEXT = 1 if $tag->[1]{class} =~ m|p-summary|;
                last;
            }
        }
    }

    if ( !$content ) {
        while ( my $tag = $p4->get_tag('div') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m/p-summary|entry-content/i ) {
                $content  = $p4->get_text('/div');
                $MORE_TEXT = 1 if $tag->[1]{class} =~ m|p-summary|;
                last;
            }
        }
    }



    if ( !$content ) {
        while ( my $tag = $p5->get_tag('div') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m|e-content|i ) {
                $content  = $p5->get_text('/div');
                $IS_NOTE = 1 if $tag->[1]{class} =~ m|p-name|i; 
                last;
            }
        }
    }

    if ( !$content ) {
        while ( my $tag = $p6->get_tag('section') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m|e-content|i ) {
                $content  = $p6->get_text('/section');
                $IS_NOTE = 1 if $tag->[1]{class} =~ m|p-name|i; 
                last;
            }
        }
    }

    if ( !$content ) {
        while ( my $tag = $p7->get_tag('p') ) {
            if ( $tag->[1]{class} and $tag->[1]{class} =~ m|e-content|i ) {
                $content  = $p7->get_text('/p');
                $IS_NOTE = 1 if $tag->[1]{class} =~ m|p-name|i; 
                last;
            }
        }
    }

    return $content;
}


sub get_article_title_from_open_graph {
    my $c = shift;

    my $title = undef;

    my $p = HTML::TokeParser->new(\$c);

    while ( my $tag = $p->get_tag('meta') ) {
        if ( $tag->[1]{property} and $tag->[1]{property} eq "og:title" ) {
            $title = $tag->[1]{content};
            last;
        }
    }

    return $title;    
}


sub get_post_content_from_open_graph {
    my $c = shift;

    my $content = undef;

    my $p = HTML::TokeParser->new(\$c);

    while ( my $tag = $p->get_tag('meta') ) {
        if ( $tag->[1]{property} and $tag->[1]{property} eq "og:description" ) {
            $content = $tag->[1]{content};
            last;
        }
    }

    return $content;    
}


sub get_content_from_article_tag {
    my $c = shift;

    my $h;

    my $p1 = HTML::TokeParser->new(\$c);
    my $p2 = HTML::TokeParser->new(\$c);
    my $p3 = HTML::TokeParser->new(\$c);

    if ( $p1->get_tag('article') ) {
        if ( $p1->get_tag('h1') ) {
            $h->{title}   = $p1->get_text('/h1');
            $h->{content} = $p1->get_text('/article');

        } elsif ( $p2->get_tag('article') ) {
            if ( $p2->get_tag('h2') ) {
                $h->{title}   = $p2->get_text('/h2');
                $h->{content} = $p2->get_text('/article');

            } elsif ( $p3->get_tag('article') ) {
                if ( $p3->get_tag('h3') ) {
                    $h->{title}   = $p3->get_text('/h3');
                    $h->{content} = $p3->get_text('/article');
                }
            }
        }
    }

    return $h
}


sub get_content_from_main_tag {
    my $c = shift;

    my $h;

    my $p1 = HTML::TokeParser->new(\$c);
    my $p2 = HTML::TokeParser->new(\$c);
    my $p3 = HTML::TokeParser->new(\$c);

    if ( $p1->get_tag('main') ) {
        if ( $p1->get_tag('h1') ) {
            $h->{title}   = $p1->get_text('/h1');
            $h->{content} = $p1->get_text('/main');

        } elsif ( $p2->get_tag('main') ) {
            if ( $p2->get_tag('h2') ) {
                $h->{title}   = $p2->get_text('/h2');
                $h->{content} = $p2->get_text('/main');

            } elsif ( $p3->get_tag('main') ) {
                if ( $p3->get_tag('h3') ) {
                    $h->{title}   = $p3->get_text('/h3');
                    $h->{content} = $p3->get_text('/main');
                }
            }
        }
    }

    return $h;
}


sub get_content_from_body_tag {
    my $c = shift;

    my $h;
    
    my $header_one_title    = HTML::TokeParser->new(\$c);
    my $header_two_title    = HTML::TokeParser->new(\$c);
    my $header_three_title  = HTML::TokeParser->new(\$c);
    my $para                = HTML::TokeParser->new(\$c);

    if ( $header_one_title->get_tag('h1') ) {
        $h->{title}   = $header_one_title->get_text('/h1');
        $h->{content} = $header_one_title->get_text('/body');

    } elsif ( $header_two_title->get_tag('h2') ) {
        $h->{title}   = $header_two_title->get_text('/h2');
        $h->{content} = $header_two_title->get_text('/body');

    } elsif ( $header_three_title->get_tag('h3') ) {
        $h->{title}   = $header_three_title->get_text('/h3');
        $h->{content} = $header_three_title->get_text('/body');
    } elsif ( $para->get_tag('p') ) {
        $h->{title}   = undef;
        $h->{content} = $para->get_text('/p');
        $MORE_TEXT = 1;
    }

    return $h;
}


# new 07aug2017
sub source_url_exists {
    my $url = shift;

    my $db_url = 'http://127.0.0.1:5984/warblerdvlp1/_design/views/_view/warblersourceurl?key="';
    $db_url .= $url . '"'; 

    my $json = get($db_url);

    my $hash_ref = decode_json $json;

    my $posts = $hash_ref->{rows};

    my $count = @$posts;

    #    print "id = " . $posts->[0]->{value}->{_id} . "\n";

    return $count;
}


# new 07aug2017
sub content_sig_exists {
    my $url = shift;
    my $domain = shift;

    my $db_url = 'http://127.0.0.1:5984/warblerdvlp1/_design/views/_view/warblercontentsig?key="';
    $db_url .= $url . '"'; 

    my $json = get($db_url);

    my $hash_ref = decode_json $json;

    my $posts = $hash_ref->{rows};

    my $count = @$posts;

    foreach my $post_ref ( @$posts ) {
        if ( $post_ref->{value}->{author_domain_name} eq $domain ) {
            return $count;
        }
    }

    return 0;
}




__END__


microformats:

ARTICLE:

h-entry 

  entry-title p-name on header (h1 or h2) usually

    entry-content e-content - not all use entry-content. entry-content used only once around the article body



NOTE:

h-entry
  entry-content e-content p-name on same container around body of note


confusing part is that some users use  p-summary, p-name, and e-content multiple times within the same page. these classes are used in the comment section around comments, webmentions, and social media shares, likes, etc. but not all indieweb users do this. frustrating because of the inconsistent or wide variable use of microformats.
  
p-name might be the most common class that is ued multiple times. example: on each response type in the comments section of the web page.


it's hard to find info about how many times a class can be used within a single web pag.

http://microformats.org/wiki/h-entry


entry-summary, e-summary, and p-summary --- why so many for what seems like the same thing?



