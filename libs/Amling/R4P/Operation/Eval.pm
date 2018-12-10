package Amling::R4P::Operation::Eval;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Eval;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation::Base::Eval');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new(
        'INPUT' => 'RECORDS',
        'RETURN' => 0,
        'OUTPUT' => 'LINES',
    );

    return $this;
}

sub names
{
    return ['eval'];
}

1;
