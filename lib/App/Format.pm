package Format;

use strict;
use warnings;
use diagnostics;


sub create_html_output {
    my $hash_ref = shift;
    my $display_type = shift;

    my $more_text = "";
    if ( $hash_ref->{more_text_exists} ) {
        $more_text = " <a href=\"$hash_ref->{source_url}\">more&gt;&gt;</a>";
    } 

    my $html_output; 

    if ( $hash_ref->{title} and $hash_ref->{html_title_tag_text} and $hash_ref->{content} ) {

        if ( $hash_ref->{content} =~ m|^\Q$hash_ref->{title}| ) {
            $hash_ref->{content} =~ s|^\Q$hash_ref->{title}||; 
            $html_output .= "<strong><span class=\"p-name\">$hash_ref->{title}</span></strong> - ";
        } elsif ( $hash_ref->{content} =~ m|^\Q$hash_ref->{html_title_tag_text}| ) {
            $hash_ref->{content} =~ s|^\Q$hash_ref->{html_title_tag_text}||; 
            $html_output .= "<strong><span class=\"p-name\">$hash_ref->{title}</span></strong> - ";
        } else {
            $html_output .= "<strong><span class=\"p-name\">$hash_ref->{title}</span></strong> - ";
        }

    } elsif ( $hash_ref->{title} ) {
        $html_output .= "<strong><span class=\"p-name\">$hash_ref->{title}</span></strong> - ";
    }

    if ( length($hash_ref->{content}) > 0 ) { 
        $html_output .= "<span class=\"p-summary\">$hash_ref->{content} $more_text</span><br />";
    }

    $html_output .= "<small> - <span class=\"p-author h-card\"><a href=\"$hash_ref->{source_url}\">$hash_ref->{author_domain_name}</a></span></small>";

    $html_output .= "<small> - <time class=\"dt-published\" datetime=\"$hash_ref->{display_date_time}\">$hash_ref->{display_date_time}</time></small>";


    if ( $display_type eq "stream" ) {
        $html_output .= "<small> - <span class=\"greenlink\"><a href=\"/thread/$hash_ref->{_id}/$hash_ref->{slug}\">Comments: $hash_ref->{comment_count}</a></span></small>";
        if ( $hash_ref->{comment_count} > 0 ) {
            if ( exists($hash_ref->{last_post_id}) ) {
                $html_output .= "<br /><small> - <span class=\"greenlink\"><a href=\"/thread/" . $hash_ref->{_id} . "#" . $hash_ref->{last_post_id} . "\">last comment</a></span>: " . Utils::format_date_time($hash_ref->{last_post_date}) . "</small>";
            } else {
                $html_output .= "<br /><small> - last comment: " . Utils::format_date_time($hash_ref->{last_post_date}) . "</small>";
            }
        }  
    } elsif ( $display_type eq "thread" ) {
        $html_output .= "<p><strong>Comments: $hash_ref->{comment_count}</strong></p>";
    } elsif ( $display_type eq "comment" ) {
        $html_output .= "<small> - <span class=\"greenlink\"><a href=\"#" . $hash_ref->{_id} . "\">#</a></span></small>";
        $html_output = "<a name=\"" . $hash_ref->{_id} . "\"></a>" . $html_output;
    }

    return $html_output;
}

1;


__END__

<p class="h-entry">
  <a class="u-url" href="http://boghop.com/2017/08/08/toledo-weather-tue-aug-8-2017.html"><span class="p-name">Toledo Weather - Tue, Aug 8, 2017</span></a>
  <br /><span class="p-summary">Pleasant weather continues. Temps were in the 50s this morning, again. A little warmer in the city. Little rain is forecast for the next seven days. We received a few sprinkles yesterday, but it was not measurable.</span>
  <br /><time class="dt-published" datetime="Tue, 08 Aug 2017 11:22:31 Z">Tue, 08 Aug 2017 11:22:31 Z</time>
  <span class="p-author h-card" style="display:none;">jr</span>
</p>

