package Amling::R4P::Deaggregator::Split;

use strict;
use warnings;

use Amling::R4P::Deaggregator::Base::OneKey;

use base ('Amling::R4P::Deaggregator::Base::OneKey');

sub new
{
    my $class = shift;
    my $old_key = shift;
    my $delim = shift;
    my $new_key = shift;

    my $this = $class->SUPER::new($old_key);

    $this->{'DELIM'} = $delim;
    $this->{'NEW_KEY'} = $new_key;

    return $this;
}

sub deaggregate1
{
    my $this = shift;
    my $value = shift;

    my $delim = $this->{'DELIM'};
    my $new_key = $this->{'NEW_KEY'};

    return [map { [[$new_key, $_]] } split(m/\Q$delim\E/, $value)];
}

sub argct
{
    return 3;
}

sub names
{
    return ['split'];
}

1;
