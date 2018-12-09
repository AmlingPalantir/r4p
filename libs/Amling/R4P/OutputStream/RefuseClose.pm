package Amling::R4P::OutputStream::RefuseClose;

use strict;
use warnings;

use Amling::R4P::OutputStream::Subs;

use base ('Amling::R4P::OutputStream::Subs');

sub new
{
    my $class = shift;
    my $os = shift;

    return $class->SUPER::new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;
            $os->write_record($r);
        },
        'WRITE_LINE' => sub
        {
            my $r = shift;
            $os->write_line($r);
        },
    );
}

1;
