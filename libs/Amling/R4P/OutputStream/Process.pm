package Amling::R4P::OutputStream::Process;

use strict;
use warnings;

use Amling::R4P::OutputStream::Lines;
use IPC::Open2;

use base ('Amling::R4P::OutputStream::Lines');

sub new
{
    my $class = shift;
    my $cmd = shift;

    my $this = $class->SUPER::new();

    my $in;
    my $out;
    my $pid = open2($in, $out, 'env', @$cmd);

    $this->{'IN'} = $in;
    $this->{'OUT'} = $out;
    $this->{'PID'} = $pid;

    return $this;
}

sub in
{
    my $this = shift;

    return $this->{'IN'};
}

sub pid
{
    my $this = shift;

    return $this->{'PID'};
}

sub write_line
{
    my $this = shift;
    my $line = shift;

    my $out = $this->{'OUT'};
    print $out "$line\n";
}

sub close
{
    my $this = shift;

    my $out = $this->{'OUT'};
    close($out);
}

1;
