package Amling::R4P::Aggregator::Base::RecordForPercentile;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Percentile;

use base ('Amling::R4P::Aggregator::Base::Percentile');

sub extra_value
{
    my $this = shift;
    my $v = shift;
    my $r = shift;

    return $r;
}

1;
