package Amling::R4P::Aggregator::DistinctCount;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKeyDistinctValues;

use base ('Amling::R4P::Aggregator::Base::OneKeyDistinctValues');

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
