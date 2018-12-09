package Amling::R4P::Aggregator::Percentile;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Percentile;

use base ('Amling::R4P::Aggregator::Base::Percentile');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 <=> $v2);
}

sub names
{
    return ['perc'];
}

1;
