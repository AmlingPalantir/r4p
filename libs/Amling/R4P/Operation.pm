package Amling::R4P::Operation;

use strict;
use warnings;

sub new
{
    my $class = shift;

    my $this =
    {
        'FILES' => [],
    };

    bless $this, $class;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        [[undef], 1, sub { $this->extra_args([@_]); return 1; }],
    ];
}

sub validate
{
    my $this = shift;

    return $this->{'FILES'};
}

sub extra_args
{
    my $this = shift;
    my $args = shift;

    push @{$this->{'FILES'}}, @$args;
}

1;
