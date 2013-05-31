package RT::Interface::Email::RequiredHeaders;

our $VERSION = '1.0';

=head1 NAME

    RT::Interface::Email::RequiredHeaders - Only accept new tickets via email with a certain header.

=head1 SYNOPSIS

    Used in conjuntion with a web-form which sends emails back to RT.
    Don't accept new emails to the Queue address.

=head1 INSTALL

    # rt/etc/RT_SiteConfig.pm

    # Make sure RT can load from its plugin dir.
    Set(@Plugins, qw/ .. RT::Interface::Email::RequiredHeaders .. /);

    # Add to incoming mail plugins list.
    # - must come before Filter::TakeAction (if present)
    Set(@MailPlugins, qw/ RequiredHeaders  Filter::TakeAction /);

    # Setup config
    #
    Set(%Plugin_RequiredHeaders, (
        "required" => [qw/X-RT-MySite/],
        # "queues"   => 1,                    # all queues
        # "queues"   => [qw/General/],      # some queues
        # "message" => "You do not have permissions to create a ticket",
    )

=head1 AUTHOR

    Alister West C<< <alister@alisterwest.com> >>

=head1 LICENCE AND COPYRIGHT

    Copyright (c) 2013, Alister West

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself. See L<perlartistic>.

=cut;

use warnings;
use strict;
use Data::Dumper; $Data::Dumper::Sortkeys=1;

use RT::Interface::Email qw(ParseCcAddressesFromHead);

=head2 GetCurrentUser

    Returns a CurrentUser object.

    MailPlugins provide this function as an interface.
    return: (CurrentUser, $auth_level) - $auth_level of -1 or -2  will halt other mail plugins.

=cut

sub GetCurrentUser {
    my %args = (
        Message       => undef,
        RawMessageRef => undef,
        CurrentUser   => undef,
        AuthLevel     => undef,
        Action        => undef,
        Ticket        => undef,
        Queue         => undef,
        @_
    );

    # Default return values - if not triggering this plugin.
    my @ret = ( $args{CurrentUser}, $args{AuthLevel});

    my %config = RT->Config->Get('Plugin_RequiredHeaders');
    my $required = $config{required};

    $RT::Logger->debug("X-RT-RequestHeaders debugging ...");
    $RT::Logger->debug(" .. Action: $args{Action}");
    $RT::Logger->debug(" .. AuthLevel: $args{AuthLevel}");
    $RT::Logger->debug(" .. CurrentUser: $args{CurrentUser}");
    $RT::Logger->debug(" .. Config: " . Dumper \%config );
    
    # If required isn't 
    $required = [] if (!$required || !ref $required || !@$required);


    # TODO - enable on/off for queues
    # my $queues   = $config{queues} || 1;
    # unless ($queues == 1 || (ref $queues eq 'ARRAY' && @$queues)) {
    #    $queues = 0;
    # }
    # Pass-through unless headed for a restricted queue
    # return (@ret, "Passthrough - Queue not restricted") if ref $queues && @$queues == 0;
    # return (@ret, "Passthrough - Queue not restricted") if $queues == 0;


    # Pass-through correspondance - we are only concerned with 'new' tickets.
    return @ret if $args{'Ticket'}->id;

    my $head = $args{'Message'}->head;
    foreach my $header (@$required) {
        if (! $head->get($header) ) {

            my $ErrorsTo = RT::Interface::Email::ParseErrorsToAddressFromHead( $head );
            RT::Interface::Email::MailError(
                To          => $ErrorsTo,
                Subject     => "Permission denied : " . $head->get('Subject'),
                Explanation => ($config{message} || "No Permissions to create this ticket" ),
                MIMEObj     => $args{'Message'}
            );

            $RT::Logger->info("ERROR - headers missing");
            return ( $args{CurrentUser}, -2 );
        }
    }

    $RT::Logger->debug(" .. Status: OK - all required headers present");
    return @ret;
}


1;
