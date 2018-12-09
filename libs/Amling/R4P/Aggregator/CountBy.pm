package Amling::R4P::Aggregator::CountBy;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKeyCounts;

use base ('Amling::R4P::Aggregator::Base::OneKeyCounts');

sub finish1
{
    my $this = shift;
    my $counts = shift;

    return $counts;
}

sub names
{
    return ['countby', 'ctby', 'cb'];
}

1;
