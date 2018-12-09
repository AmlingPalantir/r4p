package Amling::R4P::Aggregator::Last;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::OneKey;

use base ('Amling::R4P::AggregatorBase::OneKey');

sub initial
{
    return [];
}

sub update1
{
    my $this = shift;
    my $state = shift;
    my $v = shift;

    $state->[0] = $v;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state->[0];
}

sub names
{
    return ['last'];
}

1;
