package Amling::R4P::Aggregator::Hash;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::TwoKey;

use base ('Amling::R4P::AggregatorBase::TwoKey');

sub initial
{
    return {};
}

sub update1
{
    my $this = shift;
    my $state = shift;
    my $value1 = shift;
    my $value2 = shift;

    $state->{$value1} = $value2;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return {%$state};
}

sub names
{
    return ['hash'];
}

1;
