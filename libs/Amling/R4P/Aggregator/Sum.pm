package Amling::R4P::Aggregator::Sum;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Ord2Univariate;

use base ('Amling::R4P::Aggregator::Base::Ord2Univariate');

sub finish1
{
    my $this = shift;
    my $s1 = shift;
    my $sx = shift;
    my $sx2 = shift;

    return $sx;
}

sub names
{
    return ['sum'];
}

1;
