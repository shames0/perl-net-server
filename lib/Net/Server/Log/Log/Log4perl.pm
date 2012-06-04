# -*- perl -*-
#
#  Net::Server::Log::Log::Log4perl - Net::Server Logging module
#
#  $Id$
#
#  Copyright (C) 2012
#
#    Paul Seamons
#    paul@seamons.com
#
#  This package may be distributed under the terms of either the
#  GNU General Public License
#    or the
#  Perl Artistic License
#
#  All rights reserved.
#
################################################################

package Net::Server::Log::Log::Log4perl;

use strict;
use warnings;
use Log::Log4perl;

our %log4perl_map = (1 => "error", 2 => "warn", 3 => "info", 4 => "debug");

sub initialize {
    my ($class, $server) = @_;
    my $prop = $server->{'server'};

    $server->configure({
        log4perl_conf   => \$prop->{'log4perl_conf'},
        log4perl_logger => \$prop->{'log4perl_logger'},
        log4perl_poll   => \$prop->{'log4perl_poll'},
    });

    die "Must specify a log4perl_conf file" if ! $prop->{'log4perl_conf'};

    my $poll = defined($prop->{'log4perl_poll'}) ? $prop->{'log4perl_poll'} : "0";
    my $logger = $prop->{'log4perl_logger'} || "Net::Server";

    if ($poll eq "0") {
        Log::Log4perl::init($prop->{'log4perl_conf'});
    } else {
        Log::Log4perl::init_and_watch($prop->{'log4perl_conf'}, $poll);
    }

    my $l4p = Log::Log4perl->get_logger($logger);

    return sub {
        my ($level, $msg, $server_level) = @_;
        return if $level !~ /^\d+$/ || $level > ($server_level || 0);
        $level = $log4perl_map{$level} || "error";
        $l4p->$level($msg);
    };
}

1;

__END__

=head1 NAME

Net::Server::Log::Log::Log4perl - log via Log4perl

=head1 SYNOPSIS

=head1 CONFIGURATION

=over 4

=head1 log_file

To begin using Log::Log4perl logging, simply set the Net::Server
log_file configuration parameter to "Log::Log4perl".

If the magic name "Log::Log4perl" is used, all logging will be
directed to the Log4perl system.  If used, the C<log4perl_conf>,
C<log4perl_poll>, C<log4perl_logger> may also be defined.

=item log4perl_conf

Only available if C<log_file> is equal to "Log::Log4perl".  This is
the filename of the log4perl configuration file - see
L<Log::Log4perl>. If this is not set, will die on startup. If the file
is not readable, will die.

=item log4perl_poll

If set to a value, will initialise with Log::Log4perl::init_and_watch
with this polling value. This can also be the string "HUP" to re-read
the log4perl_conf when a HUP signal is received. If set to 0, no
polling is done. See L<Log::Log4perl> for more details.

=item log4perl_logger

This is the facility name. Defaults to "Net::Server".

=back

=head1 DEFAULT ARGUMENTS FOR Net::Server

The following arguments are available in the default C<Net::Server> or
C<Net::Server::Single> modules.  (Other personalities may use
additional parameters and may optionally not use parameters from the
base class.)

    Key               Value                    Default

    ## log4perl parameters (if log_file eq Log::Log4perl)
    log4perl_conf     "filename"               will die if not set
    log4perl_poll     number or HUP            0 (no polling)
    log4perl_logger   "name"                   "Net::Server"

=head1 LICENCE

Distributed under the same terms as Net::Server

=cut