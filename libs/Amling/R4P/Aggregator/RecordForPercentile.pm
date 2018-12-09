package Amling::R4P::Aggregator::RecordForPercentile;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::RecordForPercentile;

use base ('Amling::R4P::Aggregator::Base::RecordForPercentile');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 <=> $v2);
}

sub names
{
    return ['recforperc'];
}

1;
