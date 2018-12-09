package Amling::R4P::AggregatorBase::Max;

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
    my $r = shift;

    if(!@$state || $this->cmp($v, $state->[0]) > 0)
    {
        @$state = ($v);
    }
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state->[0];
}

1;
