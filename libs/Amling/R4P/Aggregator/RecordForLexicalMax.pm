package Amling::R4P::Aggregator::RecordForLexicalMax;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::RecordForMax;

use base ('Amling::R4P::AggregatorBase::RecordForMax');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 cmp $v2);
}

sub names
{
    return ['recforlmax'];
}

1;
