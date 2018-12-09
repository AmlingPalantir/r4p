package Amling::R4P::Aggregator::LexicalPercentile;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Percentile;

use base ('Amling::R4P::Aggregator::Base::Percentile');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 cmp $v2);
}

sub names
{
    return ['lperc'];
}

1;
