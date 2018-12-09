package Amling::R4P::Aggregator::Base::TwoKey;

use strict;
use warnings;

use Amling::R4P::Utils;

sub new
{
    my $class = shift;
    my $key1 = shift;
    my $key2 = shift;

    my $this =
    {
        'KEY1' => $key1,
        'KEY2' => $key2,
    };

    bless $this, $class;

    return $this;
}

sub update
{
    my $this = shift;
    my $state = shift;
    my $r = shift;

    my $value1 = Amling::R4P::Utils::get_path($r, $this->{'KEY1'});
    my $value2 = Amling::R4P::Utils::get_path($r, $this->{'KEY2'});
    $this->update1($state, $value1, $value2);
}

sub argct
{
    return 2;
}

1;
