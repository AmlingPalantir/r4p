package Amling::R4P::Aggregator::Average;

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

    return $sx / $s1;
}

sub names
{
    return ['average', 'avg'];
}

1;
