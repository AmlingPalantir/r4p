package Amling::R4P::AggregatorBase::Percentile;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::OneKey;

use base ('Amling::R4P::AggregatorBase::OneKey');

sub new
{
    my $class = shift;
    my $perc = shift;
    my $key = shift;

    my $this = $class->SUPER::new($key);

    $this->{'PERC'} = $perc;

    return $this;
}

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

    my @vals = @$state;
    @vals = sort { $this->cmp($a, $b) } @vals;

    my $idx = int(scalar(@vals) * $this->{'PERC'} / 100);
    if($idx == scalar(@vals))
    {
        --$idx;
    }

    return $vals[$idx];
}

sub argct
{
    return 2;
}

1;
