package Amling::R4P::OutputStream::SubTransform;

use strict;
use warnings;

use Amling::R4P::OutputStream::Subs;

use base ('Amling::R4P::OutputStream::Subs');

sub new
{
    my $class = shift;
    my $os = shift;
    my $sub = shift;

    return $class->SUPER::new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;
            $os->write_record($sub->($r));
        },
        'CLOSE' => sub
        {
            $os->close();
        },
    );
}

1;
