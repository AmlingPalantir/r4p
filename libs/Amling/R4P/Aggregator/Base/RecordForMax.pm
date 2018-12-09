package Amling::R4P::Aggregator::Base::RecordForMax;

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
