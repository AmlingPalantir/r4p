package Amling::R4P::Aggregator::Base::Ord2Univariate;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKey;

use base ('Amling::R4P::Aggregator::Base::OneKey');

sub initial
{
    return [0, 0, 0];
}

sub update1
{
    my $this = shift;
    my $state = shift;
    my $v = shift;

    $state->[0] += 1;
    $state->[1] += $v;
    $state->[2] += $v ** 2;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    my ($s1, $sx, $sx2) = @$state;

    return $this->finish1($s1, $sx, $sx2);
}

1;
