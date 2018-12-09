package Amling::R4P::Operation::Decollate;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Registry;
use Amling::R4P::Utils;
use Clone ('clone');

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'SPECS'} = [];

    return $this;
}

sub options
{
    my $this = shift;

    my $specs = $this->{'SPECS'};

    return
    [
        @{$this->SUPER::options()},

        @{Amling::R4P::Registry::options('Amling::R4P::Deaggregator', ['d', 'deaggregator'], ['deagg'], 0, $specs)},
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    for my $spec (reverse(@{$this->{'SPECS'}}))
    {
        $os = _wrap1($os, $spec);
    }

    return $os;
}


sub _wrap1
{
    my $os = shift;
    my $spec = shift;

    my $instance = $spec->{'instance'};

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            my $pairses = $instance->deaggregate($r);
            for my $pairs (@$pairses)
            {
                my $r2;
                if(@$pairses == 1)
                {
                    $r2 = $r;
                }
                else
                {
                    $r2 = clone($r);
                }

                for my $pair (@$pairs)
                {
                    my ($path, $value) = @$pair;

                    Amling::R4P::Utils::set_path($r2, $path, $value);
                }

                $os->write_record($r2);
            }
        },
        'CLOSE' => sub
        {
            $os->close();
        }
    );
}

sub names
{
    return ['decollate'];
}

1;
