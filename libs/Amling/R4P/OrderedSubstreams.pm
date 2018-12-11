package Amling::R4P::OrderedSubstreams;

use strict;
use warnings;

use Amling::R4P::OutputStream::Easy;

# This hideous mess is necessary because places need to make multiple
# substreams which are ordered ordered (specifically have their output
# ordered), but closing a subtream does not actually synchronously close inners
# (due to subprocesses).  We collect their writes (and closes) into buffers,
# one per stream, dumping to the top delegate where we can.

sub new
{
    my $class = shift;
    my $delegate = shift;

    my $this =
    {
        'DELEGATE' => $delegate,
        'BUFFERS' => [],
        'CLOSED' => 0,
    };

    bless $this, $class;

    return $this;
}

sub _ferry
{
    my $this = shift;

    my $delegate = $this->{'DELEGATE'};
    my $buffers = $this->{'BUFFERS'};
    my $closed = $this->{'CLOSED'};

    BUFFER: while(@$buffers)
    {
        my $buffer = $buffers->[0];
        ELEMENT: while(1)
        {
            my $e = shift(@$buffer);
            if(!$e)
            {
                return;
            }
            my ($type, @rest) = @$e;
            if($type eq 'BOF')
            {
                my ($file) = @rest;
                $delegate->write_bof($file);
                next ELEMENT;
            }
            if($type eq 'LINE')
            {
                my ($line) = @rest;
                $delegate->write_line($line);
                next ELEMENT;
            }
            if($type eq 'RECORD')
            {
                my ($r) = @rest;
                $delegate->write_record($r);
                next ELEMENT;
            }
            if($type eq 'CLOSE')
            {
                shift @$buffers;
                next BUFFER;
            }
            die;
        }
    }

    $delegate->close() if($closed);
}

sub next
{
    my $this = shift;

    my $buffer = [];
    push @{$this->{'BUFFERS'}}, $buffer;

    return Amling::R4P::OutputStream::Hard->new(
        'WRITE_BOF' => sub
        {
            my $this1 = shift;
            my $file = shift;

            push @$buffer, ['BOF', $file];
            $this->_ferry();
        },
        'WRITE_LINE' => sub
        {
            my $this1 = shift;
            my $line = shift;

            push @$buffer, ['LINE', $line];
            $this->_ferry();
        },
        'WRITE_RECORD' => sub
        {
            my $this1 = shift;
            my $r = shift;

            push @$buffer, ['RECORD', $r];
            $this->_ferry();
        },
        'CLOSE' => sub
        {
            my $this1 = shift;

            push @$buffer, ['CLOSE'];
            $this->_ferry();
        },
    );
}

sub close
{
    my $this = shift;

    # can't close until buffer is empty and we're closed!
    $this->{'CLOSED'} = 1;
    $this->_ferry();
}

1;
