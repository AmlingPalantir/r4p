package Amling::R4P::Aggregator::LexicalMin;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::Max;

use base ('Amling::R4P::AggregatorBase::Max');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v2 cmp $v1);
}

sub names
{
    return ['lmin'];
}

1;
