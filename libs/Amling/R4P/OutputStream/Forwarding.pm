package Amling::R4P::OutputStream::Forwarding;

use strict;
use warnings;

sub new
{
    my $class = shift;
    my $delegate = shift;

    my $this =
    {
        'DELEGATE' => $delegate,
    };

    bless $this, $class;

    return $this;
}

sub write_bof
{
    my $this = shift;
    my $file = shift;

    return $this->{'DELEGATE'}->write_bof($file);
}

sub write_line
{
    my $this = shift;
    my $line = shift;

    return $this->{'DELEGATE'}->write_line($line);
}

sub write_record
{
    my $this = shift;
    my $r = shift;

    return $this->{'DELEGATE'}->write_record($r);
}

sub close
{
    my $this = shift;

    return $this->{'DELEGATE'}->close();
}

1;
