package App::Dispatch;
use strict;
use warnings;
use App::Modules;

my %cgi_params = Utils::get_cgi_params_from_path_info("function", "one", "two", "three", "four");

my $dispatch_for = {
    showerror          =>   sub { return \&do_sub(       "Utils",          "do_invalid_function"      ) },
    webmention         =>   sub { return \&do_sub(       "Webmention",     "post_webmention"          ) }, 
    stream             =>   sub { return \&do_sub(       "Stream",         "show_stream"              ) },
    homepage           =>   sub { return \&do_sub(       "Stream",         "show_stream"              ) },
    thread             =>   sub { return \&do_sub(       "Thread",         "show_thread"              ) },
    startnewthread     =>   sub { return \&do_sub(       "Thread",         "show_new_thread_post_form") },
    addcomment         =>   sub { return \&do_sub(       "Comments",       "show_new_comment_form"    ) },
};

sub execute {
    my $function = $cgi_params{function};

    $dispatch_for->{stream}->() if !defined($function) or !$function;

    $dispatch_for->{showerror}->($function) unless exists $dispatch_for->{$function} ;
#    $dispatch_for->{post}->($function) unless exists $dispatch_for->{$function} ;

    defined $dispatch_for->{$function}->();
}

sub do_sub {
    my $module = shift;
    my $subroutine = shift;
    eval "require App::$module" or Page->report_error("user", "Runtime Error (1):", $@);
    my %hash = %cgi_params;
    my $coderef = "$module\:\:$subroutine(\\%hash)"  or Page->report_error("user", "Runtime Error (2):", $@);
    eval "{ &$coderef };" or Page->report_error("user", "Runtime Error (2):", $@) ;
}

1;
