package Amling::R4P::Deaggregator::Unhash;

use strict;
use warnings;

use Amling::R4P::Deaggregator::Base::OneKey;

use base ('Amling::R4P::Deaggregator::Base::OneKey');

sub new
{
    my $class = shift;
    my $old_key = shift;
    my $new_key_key = shift;
    my $new_value_key = shift;

    my $this = $class->SUPER::new($old_key);

    $this->{'NEW_KEY_KEY'} = $new_key_key;
    $this->{'NEW_VALUE_KEY'} = $new_value_key;

    return $this;
}

sub deaggregate1
{
    my $this = shift;
    my $value = shift;

    my $new_key_key = $this->{'NEW_KEY_KEY'};
    my $new_value_key = $this->{'NEW_VALUE_KEY'};

    return [map { [[$new_key_key, $_], [$new_value_key, $value->{$_}]] } keys(%$value)];
}

sub argct
{
    return 3;
}

sub names
{
    return ['unhash'];
}

1;
