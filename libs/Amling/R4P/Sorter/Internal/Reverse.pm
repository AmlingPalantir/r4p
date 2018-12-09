package Amling::R4P::Sorter::Internal::Reverse;

use strict;
use warnings;

sub new
{
    my $class = shift;
    my $delegate = shift;

    my $this =
    {
        'DELEGATE' => $delegate,
    };

    bless $this, $class;

    return $this;
}

sub cmp
{
    my $this = shift;
    my $r1 = shift;
    my $r2 = shift;

    return $this->{'DELEGATE'}->cmp($r2, $r1);
}

1;
