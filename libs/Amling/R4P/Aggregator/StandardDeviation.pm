package Amling::R4P::Aggregator::StandardDeviation;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::Ord2Univariate;

use base ('Amling::R4P::AggregatorBase::Ord2Univariate');

sub finish1
{
    my $this = shift;
    my $s1 = shift;
    my $sx = shift;
    my $sx2 = shift;

    return sqrt(($sx2 / $s1) - ($sx / $s1) ** 2);
}

sub names
{
    return ['stddev', 'sd'];
}

1;
