package Amling::R4P::Aggregator::DistinctCount;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::OneKeyDistinctValues;

use base ('Amling::R4P::AggregatorBase::OneKeyDistinctValues');

sub finish1
{
    my $this = shift;
    my $values = shift;

    return scalar(@$values);
}

sub names
{
    return ['dcount', 'dct'];
}

1;
