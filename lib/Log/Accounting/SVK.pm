package Log::Accounting::SVK;
use strict;
use warnings;
use Spiffy '-Base';
use Algorithm::Accounting;
use SVK;
use SVK::XD;
use SVK::Util qw(get_anchor catfile catdir);
use SVK::Command::Log;
use YAML;
our $VERSION = '0.03';

field 'repository';
field start_rev => 1;
field end_rev   => -1;

field 'quiet';

field '_algo';

sub process {
  $self->repository || die "Must set repository\n";
  my $acc = Algorithm::Accounting->new(fields => [qw/author path month/]);

  $self->_algo($acc);

  $ENV{HOME} ||= catdir(@ENV{qw( HOMEDRIVE HOMEPATH )});
  my $svkpath = $ENV{SVKROOT} || catfile($ENV{HOME}, ".svk");
  my $xd = SVK::XD->new ( giantlock => "$svkpath/lock",
			  statefile => "$svkpath/config",
			  svkpath => $svkpath,
			);
  $xd->load;
  my $cmd = SVK::Command::Log->new($xd);
  my $target = $cmd->parse_arg($self->repository);

  my $append = sub {
    my ($revision, $root, $paths, $props, $sep, $output, $indent, $print_rev) = @_;
    my ($author, $date) = @{$props}{qw/svn:author svn:date/};
    unless($self->quiet) {print STDERR "$revision\t\r" if($revision);}
    my $_paths = $self->_extract_path($target,$paths);
    my $_year_month  = $self->_extract_date($date);
    $acc->append_data([[ $author, $_paths , $_year_month ]]) if($author);
  };

  SVK::Command::Log::_get_logs($target->root($xd),-1,$target->{path},$target->{repos}->fs->youngest_rev,0,1,0,$append) ;
  $self->_algo($acc);
  return $self;
}

sub report {
  my $algo = $self->_algo || die("Can't report without algo obj");
  $algo->report;
}

sub result {
  my $algo = $self->_algo || die("Can't return result without algo obj");
  $algo->result(@_);
}

sub _extract_date {
# 2004-04-10T09:51:33.621682Z
  my $date = shift;
  $date =~ s/-\d+T.+$//;
  return $date;
}

# extract top-level directories into a arrayref
sub _extract_path {
  my ($target,$paths) = @_;
  return ['(DUMMY)'] unless $paths;
  my %h;
  my $prefix = $target->{path};
  $prefix = '' if($prefix eq '/');
  for(keys %$paths) {
    s/^${prefix}//;
    my @k = split(/\//,$_);
    next unless $k[1];
    $h{ "$k[1]" } = 1;
  }
  return [keys %h];
}


1;

__END__

=head1 NAME

  Log::Accounting::SVK - Accounting svn repository

=head1 SYNOPSIS

  my $acc = Log::Accounting::SVK->new(repository => 'svn://');
  $acc->process->report;

=head1 DESCRIPTION

This module make use of L<Algorithm::Accounting> and L<SVK> to do
simple accounting of any SVK repository. The installed C<svn-accounting.pl>
script demostrate a simple use to this module, you may try:

  svk-accounting.pl //

This will display all the contributions of developers under repository
'//'. You may also specify depotpath like '//trunk/svk'.

So far it's quite simple and no big deal, different fields will
be accounted in the future.

=head1 COPYRIGHT

Copyright 2004 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut

