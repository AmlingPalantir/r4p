package Amling::R4P::Aggregator::Base::ZeroArg;

use strict;
use warnings;

sub new
{
    my $class = shift;

    my $this = {};

    bless $this, $class;

    return $this;
}

sub argct
{
    return 0;
}

1;
