#!/usr/bin/perl

use strict;
use warnings;
use IO::All;
use YAML;
use Log::Accounting::SVK;
use Graph::SocialMap;
use Graph::Writer::GraphViz;

my $repo = shift || '.';
my $format = 'dot';

my $result = Log::Accounting::SVK->new(
    repository => $repo,
   )->process->group_result(0);

my $rel = hoh2hol(reversehoh($result));
my $gsm = sm( -relation => $rel );

$repo =~ s{^/+}{}; $repo =~ s{/}{.}g;
my $writer = Graph::Writer::GraphViz->new(-format => $format );
$writer->write_graph($gsm->type2, "${repo}.${format}");

sub reversehoh {
    my $hoh = shift;
    my $nhoh = {};
    for my $k1 (keys %$hoh) {
        for my $k2 (keys %{$hoh->{$k1}}) {
            $nhoh->{$k2}->{$k1} = $hoh->{$k1}->{$k2};
        }
    }
    return $nhoh;
}

sub hoh2hol {
    my $hoh = shift;
    my $hol = {};
    for my $k1 (keys %$hoh) {
        next unless $k1;
        for my $k2 (keys %{$hoh->{$k1}}) {
            push @{$hol->{$k1}||=[]},$k2;
        }
    }
    return $hol;
}

=head1 NAME

  svk-developer-graph.pl - Generate developer graph information

=head1 USAGE

  svk-developer-graph //mirror/svk

=head1 DESCRIPTION

This command visualized the developement into a developer social-network
graph using L<GraphViz>. Now it saves the graph as dot format, more
options would be supported in future releases.

=head1 COPYRIGHT

Copyright 2005 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>
