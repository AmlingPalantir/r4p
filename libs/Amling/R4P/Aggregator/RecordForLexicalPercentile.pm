package Amling::R4P::Aggregator::RecordForLexicalPercentile;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::RecordForPercentile;

use base ('Amling::R4P::AggregatorBase::RecordForPercentile');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 cmp $v2);
}

sub names
{
    return ['recforlperc'];
}

1;
