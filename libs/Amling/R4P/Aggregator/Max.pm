package Amling::R4P::Aggregator::Max;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Max;

use base ('Amling::R4P::Aggregator::Base::Max');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 <=> $v2);
}

sub names
{
    return ['max'];
}

1;
