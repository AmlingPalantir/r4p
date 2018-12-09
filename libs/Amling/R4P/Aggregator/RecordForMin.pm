package Amling::R4P::Aggregator::RecordForMin;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::RecordForMax;

use base ('Amling::R4P::Aggregator::Base::RecordForMax');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v2 <=> $v1);
}

sub names
{
    return ['recformin'];
}

1;
