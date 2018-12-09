package Amling::R4P::Sorter::Numeric;

use strict;
use warnings;

use Amling::R4P::SorterBase::OneKey;

use base ('Amling::R4P::SorterBase::OneKey');

sub cmp1
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 <=> $v2);
}

sub names
{
    return ['numeric', 'num', 'n'];
}

1;
