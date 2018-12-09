package Amling::R4P::Aggregator::DistinctArray;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKeyDistinctValues;

use base ('Amling::R4P::Aggregator::Base::OneKeyDistinctValues');

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
