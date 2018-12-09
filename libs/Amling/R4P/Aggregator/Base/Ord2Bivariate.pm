package Amling::R4P::Aggregator::Base::Ord2Bivariate;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::TwoKey;

use base ('Amling::R4P::Aggregator::Base::TwoKey');

sub initial
{
    return [0, 0, 0, 0, 0, 0];
}

sub update1
{
    my $this = shift;
    my $state = shift;
    my $x = shift;
    my $y = shift;

    $state->[0] += 1;
    $state->[1] += $x;
    $state->[2] += $y;
    $state->[3] += $x * $y;
    $state->[4] += $x ** 2;
    $state->[5] += $y ** 2;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    my ($s1, $sx, $sy, $sxy, $sx2, $sy2) = @$state;

    return $this->finish1($s1, $sx, $sy, $sxy, $sx2, $sy2);
}

1;
