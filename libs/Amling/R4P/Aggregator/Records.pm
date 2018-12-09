package Amling::R4P::Aggregator::Records;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::ZeroArg;

use base ('Amling::R4P::Aggregator::Base::ZeroArg');

sub initial
{
    return [];
}

sub update
{
    my $this = shift;
    my $state = shift;
    my $r = shift;

    push @$state, $r;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state;
}

sub names
{
    return ['records', 'recs'];
}

1;
