package Amling::R4P::AggregatorBase::OneKey;

use strict;
use warnings;

use Amling::R4P::Utils;

sub new
{
    my $class = shift;
    my $key = shift;

    my $this =
    {
        'KEY' => $key,
    };

    bless $this, $class;

    return $this;
}

sub update
{
    my $this = shift;
    my $state = shift;
    my $r = shift;

    $this->update1($state, Amling::R4P::Utils::get_path($r, $this->{'KEY'}), $r);
}

sub argct
{
    return 1;
}

1;
