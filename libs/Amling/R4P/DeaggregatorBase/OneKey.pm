package Amling::R4P::DeaggregatorBase::OneKey;

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

sub deaggregate
{
    my $this = shift;
    my $r = shift;

    return $this->deaggregate1(Amling::R4P::Utils::get_path($r, $this->{'KEY'}), $r);
}

sub argct
{
    return 1;
}

1;
