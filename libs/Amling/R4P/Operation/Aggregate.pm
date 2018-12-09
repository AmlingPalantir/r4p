package Amling::R4P::Operation::Aggregate;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Registry;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'SPECS'} = [];
    $this->{'INCREMENTAL'} = 0;

    return $this;
}

sub options
{
    my $this = shift;

    my $specs = $this->{'SPECS'};

    return
    [
        @{$this->SUPER::options()},

        @{Amling::R4P::Registry::options('Amling::R4P::Aggregator', ['a', 'aggregator'], ['agg'], 1, $specs)},
        [['incremental'], 0, \$this->{'INCREMENTAL'}],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $states = [];
    for my $spec (@{$this->{'SPECS'}})
    {
        my $name = $spec->{'label'};
        if(!defined($name))
        {
            $name = $spec->{'arg'};
            $name =~ s@/@_@g;
        }
        my $agg = $spec->{'instance'};
        push @$states, [$name, $agg, $agg->initial()];
    }
    my $incremental = $this->{'INCREMENTAL'};

    my $output_record = sub
    {
        my $r = {};
        for my $tuple (@$states)
        {
            my ($name, $agg, $state) = @$tuple;

            Amling::R4P::Utils::set_path($r, $name, $agg->finish($state));
        }
        $os->write_record($r);
    };

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            for my $tuple (@$states)
            {
                my ($name, $agg, $state) = @$tuple;

                $agg->update($state, $r);
            }

            $output_record->() if($incremental);
        },
        'CLOSE' => sub
        {
            $output_record->() unless($incremental);
            $os->close();
        },
    );
}

sub names
{
    return ['aggregate'];
}

1;
