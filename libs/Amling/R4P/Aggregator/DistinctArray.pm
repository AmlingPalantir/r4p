package Amling::R4P::Aggregator::DistinctArray;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::OneKeyDistinctValues;

use base ('Amling::R4P::AggregatorBase::OneKeyDistinctValues');

sub finish1
{
    my $this = shift;
    my $values = shift;

    return $values;
}

sub names
{
    return ['darray', 'darr'];
}

1;
