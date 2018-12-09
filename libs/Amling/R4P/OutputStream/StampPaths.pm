package Amling::R4P::OutputStream::StampPaths;

use strict;
use warnings;

use Amling::R4P::OutputStream::Forwarding;
use Amling::R4P::Utils;

use base ('Amling::R4P::OutputStream::Forwarding');

sub new
{
    my $class = shift;
    my $os = shift;
    my $pairs = shift;

    my $this = $class->SUPER::new($os);

    $this->{'PAIRS'} = $pairs;

    return $this;
}

sub write_record
{
    my $this = shift;
    my $r = shift;

    my $pairs = $this->{'PAIRS'};

    for my $pair (@$pairs)
    {
        my ($path, $value) = @$pair;

        Amling::R4P::Utils::set_path($r, $path, $value);
    }

    return $this->SUPER::write_record($r);
}

1;
