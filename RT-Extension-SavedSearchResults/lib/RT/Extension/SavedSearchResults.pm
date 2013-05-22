package RT::Extension::SavedSearchResults;

our $VERSION = 1.0;

=head1 NAME

    RT::Extension::SavedSearchResults - a short url for saved-searches

=head1 VERSION

    Version 1.0

=head1 SYNOPSIS

    http://myrt.com/Search/ResultsFromSavedSearch.tsv?SavedSearchId=123

    SavedSearchId will use /(\d+)$/ so the following are equivilent
        * 8
        * RT::System-1-SavedSearch-8
        * RT%3A%3ASystem-1-SavedSearch-8

    # View SavedSearch (stored in Attributes table)
    RT_Dir$ ./sbin/rt-attributes-viewer  8

    # Get output from saved-search and save to file.      
    RT_Dir$ ./local/plugins/RT-SavedSearchResults/bin/rt-saved-search-results.pl  8  yesterday.tsv

=head1 DESCRIPTION

    This plugin transparently changes the "Search > Feeds > Spreadsheet" link into a short url.
    
    Useful for:
        * Commandline dumps of Saved-Searches
        * MS Excel External Data-Import Feeds which currently barfs on the default long url.

=head1 AUTHOR

    Alister West, C<< <alister at alisterwest.com> >>

    Please report any bugs to the author on CPAN or github.
    This module is designed to work with RT4 and above.

=head1 LICENSE AND COPYRIGHT

    Copyright 2013 Alister West.

    This program is free software; you can redistribute it and/or modify it
    under the same terms as perl itself L<http://dev.perl.org/licenses/>.

=head1 CHANGES

    1.0 - 2013/05/17 - Created; tested with RT v4.0.12

=cut

1;
