package Amling::R4P::Aggregator::Base::OneKeyValues;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKey;

use base ('Amling::R4P::Aggregator::Base::OneKey');

sub initial
{
    return [];
}

sub update1
{
    my $this = shift;
    my $state = shift;
    my $v = shift;

    push @$state, $v;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $this->finish1($state);
}

1;
