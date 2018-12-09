package Amling::R4P::Aggregator::Base::RecordForMax;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Max;

use base ('Amling::R4P::Aggregator::Base::Max');

sub extra_value
{
    my $this = shift;
    my $v = shift;
    my $r = shift;

    return $r;
}

1;
