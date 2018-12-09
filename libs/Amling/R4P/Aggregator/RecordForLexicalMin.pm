package Amling::R4P::Aggregator::RecordForLexicalMin;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::RecordForMax;

use base ('Amling::R4P::AggregatorBase::RecordForMax');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v2 cmp $v1);
}

sub names
{
    return ['recforlmin'];
}

1;
