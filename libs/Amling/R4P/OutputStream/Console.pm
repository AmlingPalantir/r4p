package Amling::R4P::OutputStream::Console;

use strict;
use warnings;

use Amling::R4P::OutputStream::Lines;

use base ('Amling::R4P::OutputStream::Lines');

sub write_line
{
    my $this = shift;
    my $line = shift;

    print "$line\n";
}

1;
