#!/usr/bin/perl
use strict;
use warnings;
use Log::Accounting::SVK;

my $repo = shift || die "Have to give a repository path\n";

Log::Accounting::SVK->new(repository => $repo)->process->report;
