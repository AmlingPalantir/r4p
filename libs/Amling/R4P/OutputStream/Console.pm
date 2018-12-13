package Amling::R4P::OutputStream::Console;

use strict;
use warnings;

use JSON;

my $json = JSON->new();

sub new
{
    my $class = shift;

    my $this = {};

    bless $this, $class;

    return $this;
}

sub write_bof
{
}

sub write_line
{
    my $this = shift;
    my $line = shift;

    print "$line\n";
}

sub write_record
{
    my $this = shift;
    my $r = shift;

    return $this->write_line($json->encode($r));
}

sub close
{
}

1;
