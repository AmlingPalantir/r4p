package Amling::R4P::Operation::Transform;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Eval;
use JSON;

use base ('Amling::R4P::Operation::Base::Eval');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new(
        'INPUT' => 'RECORDS',
        'RETURN' => 1,
        'OUTPUT' => 'RECORDS',
    );

    return $this;
}

sub names
{
    return ['xform'];
}

1;
