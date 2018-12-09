package Amling::R4P::Aggregator::First;

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

    push @$state, $v unless(@$state);
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state->[0];
}

sub names
{
    return ['first'];
}

1;
