package Amling::R4P::Operation::Eval;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Eval;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation::Base::Eval');

sub on_value
{
    my $this = shift;
    my $os = shift;
    my $v = shift;
    my $r = shift;

    $v = Amling::R4P::Utils::pretty_string($v);

    $os->write_line($v);
}

sub names
{
    return ['eval'];
}

1;
