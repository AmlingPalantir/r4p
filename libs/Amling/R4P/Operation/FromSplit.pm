package Amling::R4P::Operation::FromSplit;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'KEYS'} = [];
    $this->{'REGEX'} = ',';

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
        [['d', 'delim'], 1, sub { my $d = '' . $_[0]; $this->{'REGEX'} = qr/\Q$d\E/; }],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $regex = $this->{'REGEX'};
    my $keys = $this->{'KEYS'};

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_LINE' => sub
        {
            my $line = shift;

            my @parts = split($regex, $line, -1);
            my $r = {};
            for(my $i = 0; $i < @parts && $i < @$keys; ++$i)
            {
                Amling::R4P::Utils::set_path($r, $keys->[$i], $parts[$i]);
            }
            $os->write_record($r);
        },
        'CLOSE' => sub
        {
            $os->close();
        }
    );
}

sub names
{
    return ['from-split'];
}

1;
