package Log::Accounting::SVK;
use Spiffy -Base;
use Algorithm::Accounting;
use SVK;
use SVK::XD;
use SVK::Util qw(get_anchor catfile catdir);
use SVK::Command::Log;
our $VERSION = '0.04';

field 'repository';
field start_rev => 1;
field end_rev   => -1;

field quiet => 0;
field image => 0;

field '_algo';

sub process {
  $self->repository || die "Must set repository\n";
  my $acc = Algorithm::Accounting->new
    ( fields       => [qw/author path month/],
      field_groups =>
      [
       [qw(author path)],
       [qw(author month)],
       [qw(author month path)]
      ]
    );

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

  SVK::Command::Log::_get_logs($target->root($xd),-1,$target->{path},0,$target->{repos}->fs->youngest_rev,1,0,$append) ;
  $self->_algo($acc);
  return $self;
}

sub report {
  my $algo = $self->_algo || die("Can't report without algo obj");
  $algo->report_class('Algorithm::Accounting::Report::GDGraph')
      if($self->image);
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


