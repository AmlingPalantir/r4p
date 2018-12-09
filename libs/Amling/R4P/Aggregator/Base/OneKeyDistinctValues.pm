package Amling::R4P::Aggregator::Base::OneKeyDistinctValues;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKey;

use base ('Amling::R4P::Aggregator::Base::OneKey');

sub initial
{
    return [[], {}];
}

sub update1
{
    my $this = shift;
    my $state = shift;
    my $v = shift;

    return if($state->[1]->{$v});
    $state->[1]->{$v} = 1;
    push @{$state->[0]}, $v;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $this->finish1([@{$state->[0]}]);
}

1;
