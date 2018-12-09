package Amling::R4P::OutputStream::StampPaths;

use strict;
use warnings;

use Amling::R4P::OutputStream::SubTransform;
use Amling::R4P::Utils;

use base ('Amling::R4P::OutputStream::SubTransform');

sub new
{
    my $class = shift;
    my $os = shift;
    my $pairs = shift;

    return $class->SUPER::new($os, sub
    {
        my $r = shift;
        for my $pair (@$pairs)
        {
            my ($path, $value) = @$pair;

            Amling::R4P::Utils::set_path($r, $path, $value);
        }
        return $r;
    });
}

1;
