package Amling::R4P::OutputStream::Easy;

use strict;
use warnings;

use Amling::R4P::OutputStream::Hard;
use JSON;

use base ('Amling::R4P::OutputStream::Hard');

my $json = JSON->new();

my $short =
{
    'BOF' =>
    {
        'PASS' => sub
        {
            my $this = shift;
            my $file = shift;
            return $this->{'DELEGATE'}->write_bof($file);
        },
        'DROP' => sub
        {
        },
    },
    'LINE' =>
    {
        'PASS' => sub
        {
            my $this = shift;
            my $line = shift;
            return $this->{'DELEGATE'}->write_line($line);
        },
        'DROP' => sub
        {
        },
        'DECODE' => sub
        {
            my $this = shift;
            my $line = shift;
            return $this->write_record($json->decode($line));
        },
    },
    'RECORD' =>
    {
        'PASS' => sub
        {
            my $this = shift;
            my $r = shift;
            return $this->{'DELEGATE'}->write_record($r);
        },
        'DROP' => sub
        {
        },
        'ENCODE' => sub
        {
            my $this = shift;
            my $r = shift;
            return $this->write_line($json->encode($r));
        },
    },
};

sub new
{
    my $class = shift;
    my $delegate = shift;
    my %args = @_;

    my %args2;

    for my $type ('BOF', 'RECORD', 'LINE')
    {
        my $v = delete $args{$type} || die "No $type specified?";
        my $v2;
        if(ref($v) eq 'CODE')
        {
            $v2 = sub
            {
                my $this = shift;
                return $v->(@_);
            };
        }
        elsif(ref($v) eq '')
        {
            $v2 = $short->{$type}->{$v} || die "Invalid short $v for $type";
        }
        else
        {
            die;
        }
        $args2{"WRITE_$type"} = $v2;
    }
    my $preclose = delete($args{'CLOSE'}) || sub {};
    $args2{'CLOSE'} = sub
    {
        $preclose->();
        $delegate->close();
    };

    my $this = $class->SUPER::new(%args2);

    $this->{'DELEGATE'} = $delegate;

    return $this;
}

1;
