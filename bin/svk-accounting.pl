#!/usr/bin/perl
use Log::Accounting::SVK;
use Getopt::Std;
my %opts;
getopts('qi',\%opts);

my $repo = shift || '.';

Log::Accounting::SVK->new(
    repository => $repo,
    quiet => $opts{q},
    image => $opts{i},
    dir => !$opts{p},
   )->process->report;

__END__

=head1 NAME

svk-accounting.pl - show accounting information of your SVK repository.

=head1 SYNOPSIS

  # Use repository path
  svk-accounting.pl //

  # Use check-out path
  svk-accounting.pl ~/dev/svk

  # Use cwd
  cd ~/dev/svk
  svk-accounting.pl

=head1 OPTIONS

  -q    Do it quietly.
  -i    Generate image report. (experimental)

=head1 DESCRIPTION

This script is a simlpe front-end to L<Log::Accounting::SVK>, It
accept one argument, which can be either a repository path or a
check-out path, and then display accounting information, including
author, immediate paths under it, and year-month. One can see
different contirbution made by developers, to different paths, and
during different period of time.

=head1 TODO

Image report are still under experimental, it creates a lots of images
under current working directory without proper file-name. This
will be changed in the future.

=head1 SEE ALSO

L<Log::Accounting>,L<SVK>,L<Algorithm::Accounting>

=head1 COPYRIGHT

Copyright 2004 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut
