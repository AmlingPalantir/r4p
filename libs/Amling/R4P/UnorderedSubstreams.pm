package Amling::R4P::UnorderedSubstreams;

use strict;
use warnings;

use Amling::R4P::OutputStream::Easy;

sub new
{
    my $class = shift;
    my $delegate = shift;

    my $this =
    {
        'DELEGATE' => $delegate,
        'OPEN' => 1,
    };

    bless $this, $class;

    return $this;
}

sub next
{
    my $this = shift;

    ++$this->{'OPEN'};

    return Amling::R4P::OutputStream::Hard->new(
        'WRITE_BOF' => sub
        {
            my $this1 = shift;
            my $file = shift;

            $this->{'DELEGATE'}->write_bof($file);
        },
        'WRITE_LINE' => sub
        {
            my $this1 = shift;
            my $line = shift;

            $this->{'DELEGATE'}->write_line($line);
        },
        'WRITE_RECORD' => sub
        {
            my $this1 = shift;
            my $r = shift;

            $this->{'DELEGATE'}->write_record($r);
        },
        'CLOSE' => sub
        {
            my $this1 = shift;

            $this->close();
        },
    );
}

sub close
{
    my $this = shift;

    if(--$this->{'OPEN'} == 0)
    {
        $this->{'DELEGATE'}->close();
    }
}

1;
