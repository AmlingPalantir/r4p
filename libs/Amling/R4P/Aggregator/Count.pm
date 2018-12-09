package Amling::R4P::Aggregator::Count;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::ZeroArg;

use base ('Amling::R4P::AggregatorBase::ZeroArg');

sub initial
{
    return [0];
}

sub update
{
    my $this = shift;
    my $state = shift;
    my $r = shift;

    $state->[0]++;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state->[0];
}

sub names
{
    return ['count', 'ct'];
}

1;
