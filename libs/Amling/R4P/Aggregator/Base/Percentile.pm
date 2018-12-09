package Amling::R4P::Aggregator::Base::Percentile;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::OneKey;

use base ('Amling::R4P::Aggregator::Base::OneKey');

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
    my $r = shift;

    push @$state, [$v, $this->extra_value($v, $r)];
}

sub extra_value
{
    my $this = shift;
    my $v = shift;
    my $r = shift;

    return $v;
}

sub finish
{
    my $this = shift;
    my $state = shift;

    my @pairs = @$state;
    @pairs = sort { $this->cmp($a->[0], $b->[0]) } @pairs;

    my $idx = int(scalar(@pairs) * $this->{'PERC'} / 100);
    if($idx == scalar(@pairs))
    {
        --$idx;
    }

    return $pairs[$idx]->[1];
}

sub argct
{
    return 2;
}

1;
