package Amling::R4P::AggregatorBase::RecordForMax;

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
        @$state = ($v, $r);
    }
}

sub finish
{
    my $this = shift;
    my $state = shift;

    my ($v, $r) = @$state;

    return $r;
}

1;
