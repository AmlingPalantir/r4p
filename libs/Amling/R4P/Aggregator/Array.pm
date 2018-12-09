package Amling::R4P::Aggregator::Array;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::OneKeyValues;

use base ('Amling::R4P::AggregatorBase::OneKeyValues');

sub finish1
{
    my $this = shift;
    my $values = shift;

    return $values;
}

sub names
{
    return ['array', 'arr'];
}

1;
