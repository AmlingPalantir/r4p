package Amling::R4P::OutputStream::Subs;

use strict;
use warnings;

use JSON;

my $json = JSON->new();

sub new
{
    my $class = shift;
    my %args = @_;

    my $this =
    {
    };
    for my $k ('WRITE_BOF', 'WRITE_RECORD', 'WRITE_LINE', 'CLOSE')
    {
        $this->{$k} = $args{$k};
    }

    bless $this, $class;

    return $this;
}

sub write_bof
{
    my $this = shift;
    my $file = shift;

    my $write_bof = $this->{'WRITE_BOF'};
    return $write_bof->($file) if(defined($write_bof));
}

sub write_line
{
    my $this = shift;
    my $line = shift;

    my $write_line = $this->{'WRITE_LINE'};
    return $write_line->($line) if(defined($write_line));

    my $write_record = $this->{'WRITE_RECORD'};
eval { $json->decode($line); }; use Carp; confess $@ if($@);
    return $write_record->($json->decode($line)) if(defined($write_record));

    die "No write impl?";
}

sub write_record
{
    my $this = shift;
    my $record = shift;

    my $write_record = $this->{'WRITE_RECORD'};
    return $write_record->($record) if(defined($write_record));

    my $write_line = $this->{'WRITE_LINE'};
    return $write_line->($json->encode($record)) if(defined($write_line));

    die "No write impl?";
}

sub close
{
    my $this = shift;

    my $close = $this->{'CLOSE'};
    return $close->() if(defined($close));
}

1;
