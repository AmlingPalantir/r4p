package Amling::R4P::Aggregator::Concat;

use strict;
use warnings;

use Amling::R4P::AggregatorBase::OneKeyValues;

use base ('Amling::R4P::AggregatorBase::OneKeyValues');

sub new
{
    my $class = shift;
    my $delim = shift;
    my $key = shift;

    my $this = $class->SUPER::new($key);

    $this->{'DELIM'} = $delim;

    return $this;
}

sub finish1
{
    my $this = shift;
    my $values = shift;

    return join($this->{'DELIM'}, @$values);
}

sub argct
{
    return 2;
}

sub names
{
    return ['concatenate', 'concat'];
}

1;
