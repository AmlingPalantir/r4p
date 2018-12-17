package Amling::R4P::Aggregator::LastRecords;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::ZeroArg;

use base ('Amling::R4P::Aggregator::Base::ZeroArg');

sub new
{
    my $class = shift;
    my $n = shift;

    my $this = $class->SUPER::new();

    $this->{'N'} = $n;

    return $this;
}

sub initial
{
    return [];
}

sub update
{
    my $this = shift;
    my $state = shift;
    my $r = shift;

    my $n = $this->{'N'};

    push @$state, $r;
    shift @$state if(@$state > $n);
}

sub finish
{
    my $this = shift;
    my $state = shift;

    return $state;
}

sub argct
{
    return 1;
}

sub names
{
    return ['lastrecords', 'lastrecs'];
}

1;
