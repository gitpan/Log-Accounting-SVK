#!/usr/bin/perl
use strict;
use warnings;
use Log::Accounting::SVK;

my $repo = shift || '.';

Log::Accounting::SVK->new(repository => $repo)->process->report;
