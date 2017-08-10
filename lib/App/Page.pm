package Page;

use strict;
use warnings;
use diagnostics;
use NEXT;

{
    $CGI::HEADERS_ONCE=1;

    use HTML::Template;

    sub new {
        my ($class, $template_name) = @_;
                 
        my $self = {
            TMPL  => undef,
            NAME  => undef,
            ERROR => 0,
            ERROR_MESSAGE => undef
        };

        my $template_home;

        $template_home = Config::get_value_for("template_home");

        $ENV{HTML_TEMPLATE_ROOT}    = $template_home;
        $self->{NAME} = $template_name;
        
        my $result = eval {
            $self->{TMPL} = HTML::Template->new(filename => "$template_home/$template_name.tmpl");
        };
        unless ($result) {
            $self->{ERROR} = 1;
            $self->{ERROR_MESSAGE} = $@;
        }

        bless($self, $class);
                 
        return $self;
    }

    sub is_error {
        my ($self) = @_;
        return $self->{ERROR};
    }

    sub get_error_message {
        my ($self) = @_;
        return $self->{ERROR_MESSAGE};
    }

    sub get_template_name {
        my ($self) = @_;
        return $self->{NAME};
    }

    sub set_template_variable {
        my ($self, $var_name, $var_value) = @_;
        $self->{TMPL}->param("$var_name"  =>   $var_value); 
    }

    sub set_template_loop_data {
        my ($self, $loop_name, $loop_data) = @_;
        $self->{TMPL}->param("$loop_name"  =>   $loop_data); 
    }

    sub print_template {
        my ($self, $content_type) = @_;
        print $content_type . "\n\n";
        print $self->{TMPL}->output;
        exit;
    }

    sub create_html {
        my ($self, $function) = @_;

        my $site_name = Config::get_value_for("site_name");
        __set_template_variable($self, "home_page",           Config::get_value_for("home_page")); 
        __set_template_variable($self, "webmention_endpoint", Config::get_value_for("webmention_endpoint")); 
#        __set_template_variable($self, "site_name",         $site_name); 
        __set_template_variable($self, "pagetitle",         "$function | $site_name");
#        __set_template_variable($self, "site_description",  Config::get_value_for("site_description"));
#        __set_template_variable($self, "css_dir_url",       Config::get_value_for("css_dir_url")); 

        return $self->{TMPL}->output;
    }

    sub display_page_min {
        my ($self, $function) = @_;

        my @http_header = ("Content-type: text/html;\n\n", "");
        my $http_header_var = 0;
        print $http_header[$http_header_var]; 

        my $site_name       =  Config::get_value_for("site_name");

        __set_template_variable($self, "home_page",    Config::get_value_for("home_page"));
        __set_template_variable($self, "webmention_endpoint", Config::get_value_for("webmention_endpoint")); 
#        __set_template_variable($self, "site_name",    $site_name);

        print $self->{TMPL}->output;

        exit;
    }

    sub display_page {
        my ($self, $function, $cache_it, $post_id) = @_;

        my @http_header = ("Content-type: text/html;\n\n", "");
        my $http_header_var = 0;
        print $http_header[$http_header_var]; 

        # format as:  Jul 18, 2013 - 8:43 p.m. EDT

        my $site_name = Config::get_value_for("site_name");
        __set_template_variable($self, "home_page",         Config::get_value_for("home_page")); 
        __set_template_variable($self, "webmention_endpoint", Config::get_value_for("webmention_endpoint")); 
#        __set_template_variable($self, "site_name",         $site_name); 
        __set_template_variable($self, "pagetitle",         "$function | $site_name");
#        __set_template_variable($self, "site_description",  Config::get_value_for("site_description"));
#        __set_template_variable($self, "css_dir_url",       Config::get_value_for("css_dir_url")); 

        if ( $cache_it ) {
            my $key;
            my $hashname =  Config::get_value_for("domain_name");

            require Cache::Memcached::libmemcached;
            my $port = Config::get_value_for("memcached_port");
               $key  = $hashname . "-" . $post_id;
            my $memd = Cache::Memcached::libmemcached->new( { 'servers' => [ "127.0.0.1:$port" ] } );
            my $html = $self->{TMPL}->output . "\n<!-- memcached built after reading -->\n";
            my $rc   = $memd->set($key, $html);
        }

        print $self->{TMPL}->output;
        exit;
    }

    sub report_error
    {
        my ($self, $type, $cusmsg, $sysmsg) = @_;
        my $o = $self->new("$type" . "error");

        $o->set_template_variable("cusmsg", "$cusmsg");

        if ( $type eq "user" ) { 
            $o->set_template_variable("sysmsg", "$sysmsg");
        } elsif ( ($type eq "system") and Config::get_value_for("debug_mode") ) {
            $o->set_template_variable("sysmsg", "$sysmsg");
        }
        $o->display_page("Error");
        exit;
    }

    sub success
    {
        my ($self, $title, $para1, $para2) = @_;
        my $o = $self->new("success");
        $o->set_template_variable("para1", $para1);
        $o->set_template_variable("para2", $para2);
        $o->display_page("Success - " . $title);
        exit;
    }

    sub DESTROY {
        my ($self) = @_;
        $self->EVERY::__destroy;
    }


    ##### private routines 
    sub __destroy {
        my ($self) = @_;
        delete $self->{TMPL};
    }

    sub __set_template_variable {
        my ($self, $var_name, $var_value) = @_;
        $self->{TMPL}->param("$var_name"  =>   $var_value); 
    }

}

1;
