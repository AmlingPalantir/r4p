package Amling::R4P::Operation::Grep;

use strict;
use warnings;

use Amling::R4P::OperationBase::Eval;

use base ('Amling::R4P::OperationBase::Eval');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'INVERT'} = 0;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        ['v'], 0, \$this->{'INVERT'},
    ];
}

sub on_value
{
    my $this = shift;
    my $os = shift;
    my $v = shift;
    my $r = shift;

    if($this->{'INVERT'})
    {
        return if($v);
    }
    else
    {
        return unless($v);
    }

    $os->write_record($r);
}

sub names
{
    return ['grep'];
}

1;
