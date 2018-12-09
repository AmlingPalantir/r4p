package Amling::R4P::Deaggregator::Unarray;

use strict;
use warnings;

use Amling::R4P::DeaggregatorBase::OneKey;

use base ('Amling::R4P::DeaggregatorBase::OneKey');

sub new
{
    my $class = shift;
    my $old_key = shift;
    my $new_key = shift;

    my $this = $class->SUPER::new($old_key);

    $this->{'NEW_KEY'} = $new_key;

    return $this;
}

sub deaggregate1
{
    my $this = shift;
    my $value = shift;

    my $new_key = $this->{'NEW_KEY'};

    return [map { [[$new_key, $_]] } @$value];
}

sub argct
{
    return 2;
}

sub names
{
    return ['unarray', 'unarr'];
}

1;
