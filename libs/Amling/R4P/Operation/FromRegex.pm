package Amling::R4P::Operation::FromRegex;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Easy;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'KEYS'} = [];
    $this->{'REGEX'} = undef;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        [['k', 'key'], 1, sub { push @{$this->{'KEYS'}}, split(',', $_[0]); }],
        [['re', 'regex'], 1, \$this->{'REGEX'}],
    ];
}

sub validate
{
    my $this = shift;

    die 'No regex provided.' unless(defined($this->{'REGEX'}));

    return $this->SUPER::validate();
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;

    my $regex = $this->{'REGEX'};
    my $keys = $this->{'KEYS'};

    return Amling::R4P::OutputStream::Easy->new(
        $os,
        'BOF' => 'PASS',
        'LINE' => sub
        {
            my $line = shift;

            if(my @groups = ($line =~ $regex))
            {
                my $r = {};
                for(my $i = 0; $i < @groups && $i < @$keys; ++$i)
                {
                    Amling::R4P::Utils::set_path($r, $keys->[$i], $groups[$i]);
                }
                $os->write_record($r);
            }
        },
        'RECORD' => 'ENCODE',
    );
}

sub names
{
    return ['from-re'];
}

1;
