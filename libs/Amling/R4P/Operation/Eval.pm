package Amling::R4P::Operation::Eval;

use strict;
use warnings;

use Amling::R4P::OperationBase::Eval;
use JSON;

use base ('Amling::R4P::OperationBase::Eval');

my $json = JSON->new();

sub on_value
{
    my $this = shift;
    my $os = shift;
    my $v = shift;
    my $r = shift;

    if(!defined($v))
    {
        $v = '';
    }
    if(ref($v) ne '')
    {
        $v = $json->encode($v);
    }

    $os->write_line($v);
}

sub names
{
    return ['eval'];
}

1;
