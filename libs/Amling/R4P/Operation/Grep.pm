package Amling::R4P::Operation::Grep;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Eval;

use base ('Amling::R4P::Operation::Base::Eval');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new(
        'INPUT' => 'RECORDS',
        'RETURN' => 0,
        'OUTPUT' => 'GREP',
    );

    return $this;
}

sub names
{
    return ['grep'];
}

1;
