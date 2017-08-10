package Utils;

use strict;
use warnings;

use Time::Local;

sub create_datetime_stamp {
    my $minutes_to_add = shift;

    # creates string for DATETIME field in database as
    # YYYY/MM/DD HH:MM:SS    (24 hour time)
    # Date and time is GMT not local.

    if ( !$minutes_to_add ) {
        $minutes_to_add = 0;
    }

    my $epochsecs = time() + ($minutes_to_add * 60);
    my ($sec, $min, $hr, $mday, $mon, $yr)  = (gmtime($epochsecs))[0,1,2,3,4,5];
    my $datetime = sprintf "%04d/%02d/%02d %02d:%02d:%02d", 2000 + $yr-100, $mon+1, $mday, $hr, $min, $sec;
    return $datetime;
}

sub create_random_string {
    my @chars = ("A".."Z", "a".."z", "0" .. "9");
    my $string;
    $string .= $chars[rand @chars] for 1..8;
    return $string;
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

# todo is this used? What about a perl module?
sub url_encode {
    my $text = shift;
    $text =~ s/([^a-z0-9_.!~*'() -])/sprintf "%%%02X", ord($1)/eig;
    $text =~ tr/ /+/;
    return $text;
}

# todo is this needed?
sub url_decode {
    my $text = shift;
    $text =~ tr/\+/ /;
    $text =~ s/%([a-f0-9][a-f0-9])/chr( hex( $1 ) )/eig;
    return $text;
}

sub url_to_link {
    my $str_orig = shift;
    # from Greymatter
    # two lines of code written in part by Neal Coffey (cray@indecisions.org)
    $str_orig =~ s#(^|\s)(\w+://)([A-Za-z0-9?=:\|;,_\-/.%+&'~\(\)\#@!\^]+)#$1<a href="$2$3">$2$3</a>#isg;
        $str_orig =~ s#(^|\s)(www.[A-Za-z0-9?=:\|;,_\-/.%+&'~\(\)\#@!\^]+)#$1<a href="http://$2">$2</a>#isg;

    # next line a modification from jr to accomadate e-mail links created with anchor tag
    $str_orig =~ s/(^|\s)(\w+\@\w+\.\w+)/<a href="mailto:$2">$1$2<\/a>/isg;
    return $str_orig;
}

sub br_to_newline {
    my $str = shift;
    $str =~ s/<br \/>/\r\n/g;
    return $str;
}

sub remove_html {
    my $str = shift;
    # remove ALL html
    $str =~ s/<([^>])+>|&([^;])+;//gsx;
    return $str;
}

sub newline_to_br {
    my $str = shift;
    $str =~ s/[\r][\n]/<br \/>/g;
    $str =~ s/[\n]/<br \/>/g;
    return $str;
}

sub remove_newline {
    my $str = shift;
#    $str =~ s/[\r][\n]//gs;
#    $str =~ s/\n.*//s;
#    $str =~ s/\s.*//s;
    $str =~ s/\n/ /gs;
    return $str;
}

sub is_numeric {
    my $str = shift;
    my $rc = 0;
    return $rc if !$str;
    if ( $str =~ m|^[0-9]+$| ) {
        $rc = 1;
    }
    return $rc;
}

sub is_float {
    my $str = shift;
    my $rc = 0;
    if ( $str =~ m|^[0-9\.]+$| ) {
        $rc = 1;
    }
    return $rc;
}

sub trim_br {
    my $str = shift;
    # remove leading <br />
    $str =~ s|^(<br />)+||g;
    # remove trailing br 
    $str =~ s|(<br />)+$||g;
    return $str;
}

sub round {
    my $number = shift;
    return int($number + .5 * ($number <=> 0));
}

# http://stackoverflow.com/questions/77226/how-can-i-capitalize-the-first-letter-of-each-word-in-a-string-in-perl
sub ucfirst_each_word {
    my $str = shift;
    $str =~ s/(\w+)/\u$1/g;
    return $str;
}
    
sub is_valid_email {
  my $mail = shift;                                                  #in form name@host
  return 0 if ( $mail !~ /^[0-9a-zA-Z\.\-\_]+\@[0-9a-zA-Z\.\-]+$/ ); #characters allowed on name: 0-9a-Z-._ on host: 0-9a-Z-. on between: @
  return 0 if ( $mail =~ /^[^0-9a-zA-Z]|[^0-9a-zA-Z]$/);             #must start or end with alpha or num
  return 0 if ( $mail !~ /([0-9a-zA-Z]{1})\@./ );                    #name must end with alpha or num
  return 0 if ( $mail !~ /.\@([0-9a-zA-Z]{1})/ );                    #host must start with alpha or num
  return 0 if ( $mail =~ /.\.\-.|.\-\..|.\.\..|.\-\-./g );           #pair .- or -. or -- or .. not allowed
  return 0 if ( $mail =~ /.\.\_.|.\-\_.|.\_\..|.\_\-.|.\_\_./g );    #pair ._ or -_ or _. or _- or __ not allowed
  return 0 if ( $mail !~ /\.([a-zA-Z]{2,3})$/ );                     #host must end with '.' plus 2 or 3 alpha for TopLevelDomain (MUST be modified in future!)
  return 1;
}

sub clean_title {
    my $str = shift;
    $str =~ s|[ ]|_|g;
    $str =~ s|[:]|_|g;
    # only use alphanumeric, underscore, and dash in wiki link url
    $str =~ s|[^\w-]+||g;
#    $str =~ s|[^a-zA-Z_0-9-]+||g;
#    $str =~ s|[^a-zA-Z_0-9-:]+||g;
    return $str;
}
   
sub shuffle_array {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i, $j] = @$array[$j,$i];
    }
}

sub quote_string {
    my $str = shift;
    return "NULL" unless defined $str;
    $str =~ s/'/''/g;
    return "'$str'";
}

sub do_invalid_function {
    my ($tmp_hash) = @_;
    my $function = $tmp_hash->{function};
    $function = "unknown" if !$function;
    Page->report_error("user", "Client Invalid function: $function", "It's not supported.");
    exit;
}

sub get_cgi_params_from_path_info {
    my @param_names = @_;
    my %params;
    my $path_info = $ENV{REQUEST_URI}; # with nginx confi, using this instead of PATH_INFO

    my @values = ();
    # remove dummy .html extension if exists
    if ( $path_info ) {
        $path_info =~ s/\.html//g; 
        $path_info =~ s/\/api\/v1//g;
        # if url = /cgi-bin/comments.pl/30/123/0/1, path_info will equal /30/123/0/1
        # this substitution removes leading forward slash before the 30.
        $path_info =~ s/\/// if ( $path_info );
        @values = split(/\//, $path_info);
    }
    my $len = @values;
    for (my $i=0; $i<$len; $i++) {
        $params{$param_names[$i]} = $values[$i];
    }
    return %params;
}

# hashtag suport sub
# my @tags     = Utils::create_tag_array($markup);
#    'tags'              =>  \@tags,
sub create_tag_array {
    my $str = shift; # using the markup code content

    my $tag_list_str = "";

    $str = " " . $str . " "; # hack to make regex work
    my @tags = ();
    my @unique_tags = (); 
    if ( (@tags = $str =~ m|\s#(\w+)|gsi) ) {
        $tag_list_str = "|";
            foreach (@tags) {
               my $tmp_tag = $_;
               # next if  Utils::is_numeric($tmp_tag); 
               if ( $tag_list_str !~ m|$tmp_tag| ) {
                   $tag_list_str .= "$tmp_tag|";
                   push(@unique_tags, $tmp_tag); 
               }
           }
    }
    return @unique_tags;
}

sub hashtag_to_link {
    my $str = shift;

    $str = " " . $str . " "; # hack to make regex work

    my @tags = ();
    my $tagsearchstr = "";
    my $tagsearchurl = "/tag/";
    if ( (@tags = $str =~ m|\s#(\w+)|gsi) ) {
            foreach (@tags) {
                next if  is_numeric($_); 
                $tagsearchstr = " <a href=\"$tagsearchurl$_\">#$_</a>";
                $str =~ s|\s#$_|$tagsearchstr|is;
        }
    }
    $str = trim_spaces($str);
    return $str;
}

sub format_date_time{
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

sub remove_power_commands {
    my $str = shift;
    # url_to_link=yes|no
    # hash_to_link=yes|no
    # markdown=yes|no
    $str =~ s|^url_to_link[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^hashtag_to_link[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^markdown[\s]*=[\s]*[noNOyesYES]+||mig;
    return $str;
}

sub get_power_command_on_off_setting_for {
    my ($command, $str, $default_value) = @_;

    my $binary_value = $default_value;   # default value should come from config file
    
    if ( $str =~ m|^$command[\s]*=[\s]*(.*?)$|mi ) {
        my $string_value = Utils::trim_spaces(lc($1));
        if ( $string_value eq "no" ) {
            $binary_value = 0;
        } elsif ( $string_value eq "yes" ) {
            $binary_value = 1;
        }
    }
    return $binary_value;
}

sub custom_commands {
    my $formattedcontent = shift;
    my $postid = shift;

    # q. and q..
    # br.
    # hr.
    # more.
    # pq. and pq..

#    $formattedcontent =~ s/^q[.][.]/\n<\/div>/igm;
#    $formattedcontent =~ s/^q[.]/<div class="highlighted" markdown="1">\n/igm;

    $formattedcontent =~ s/^q[.][.]/\n<\/blockquote>/igm;
    $formattedcontent =~ s/^q[.]/<blockquote class="highlighted" markdown="1">\n/igm;

    $formattedcontent =~ s/^hr[.]/<hr class="shortgrey" \/>/igm;

    $formattedcontent =~ s/^br[.]/<br \/>/igm;

    $formattedcontent =~ s/^more[.]/<more \/>/igm;

    $formattedcontent =~ s/pq[.][.]/<\/em><\/big><\/center>/igm;
    $formattedcontent =~ s/^pq[.]/<center><big><em>/igm;

    return $formattedcontent;
}

1;

