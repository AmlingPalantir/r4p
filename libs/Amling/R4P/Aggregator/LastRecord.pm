package Amling::R4P::Aggregator::LastRecord;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::ZeroArg;

use base ('Amling::R4P::Aggregator::Base::ZeroArg');

sub initial
{
    return [undef];
}

sub update
{
    my $this = shift;
    my $state = shift;
    my $r = shift;

    $state->[0] = $r;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state->[0];
}

sub names
{
    return ['lastrecord', 'lastrec'];
}

1;
