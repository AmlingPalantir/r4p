package Amling::R4P::OutputStream::RefuseClose;

use strict;
use warnings;

use Amling::R4P::OutputStream::Hard;

use base ('Amling::R4P::OutputStream::Hard');

sub new
{
    my $class = shift;
    my $os = shift;

    return $class->SUPER::new(
        'WRITE_BOF' => sub
        {
            my $this = shift;
            my $file = shift;
            $os->write_bof($file);
        },
        'WRITE_RECORD' => sub
        {
            my $this = shift;
            my $r = shift;
            $os->write_record($r);
        },
        'WRITE_LINE' => sub
        {
            my $this = shift;
            my $r = shift;
            $os->write_line($r);
        },
        'CLOSE' => sub
        {
        },
        'RCLOSED' => sub
        {
            return $os->rclosed();
        },
    );
}

1;
