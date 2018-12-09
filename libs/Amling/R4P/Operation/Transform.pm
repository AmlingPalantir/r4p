package Amling::R4P::Operation::Transform;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Eval;
use JSON;

use base ('Amling::R4P::Operation::Base::Eval');

my $json = JSON->new();

sub on_value
{
    my $this = shift;
    my $os = shift;
    my $v = shift;
    my $r = shift;

    if(UNIVERSAL::isa($v, 'ARRAY'))
    {
        for my $r1 (@$v)
        {
            $os->write_record($r1);
        }
        return;
    }

    $os->write_record($v);
}

sub return
{
    return 'r';
}

sub names
{
    return ['xform'];
}

1;
