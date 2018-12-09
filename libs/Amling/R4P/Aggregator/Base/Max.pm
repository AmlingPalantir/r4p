package Amling::R4P::Aggregator::Base::Max;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKey;

use base ('Amling::R4P::Aggregator::Base::OneKey');

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
        @$state = ($v, $this->extra_value($v, $r));
    }
}

sub extra_value
{
    my $this = shift;
    my $v = shift;
    my $r = shift;

    return $v;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state->[1];
}

1;
