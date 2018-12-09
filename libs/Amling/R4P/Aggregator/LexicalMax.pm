package Amling::R4P::Aggregator::LexicalMax;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Max;

use base ('Amling::R4P::Aggregator::Base::Max');

sub cmp
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 cmp $v2);
}

sub names
{
    return ['lmax'];
}

1;
