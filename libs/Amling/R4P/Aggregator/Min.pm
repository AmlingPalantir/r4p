package Amling::R4P::Aggregator::Min;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Max;

use base ('Amling::R4P::Aggregator::Base::Max');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v2 <=> $v1);
}

sub names
{
    return ['min'];
}

1;
