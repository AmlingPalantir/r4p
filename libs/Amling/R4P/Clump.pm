package Amling::R4P::Clump;

use strict;
use warnings;

use Amling::R4P::Clumper::Key;
use Amling::R4P::Registry;

sub new
{
    my $class = shift;

    my $this =
    {
        'SPECS' => [],
    };

    bless $this, $class;

    return $this;
}

sub options
{
    my $this = shift;

    my $specs = $this->{'SPECS'};

    return
    [
        @{Amling::R4P::Registry::options('Amling::R4P::Clumper', ['c', 'clumper'], ['cl'], 0, $specs)},
        [['k', 'key'], 1, sub
        {
            for my $key (split(/,/, $_[0]))
            {
                push @$specs,
                {
                    'instance' => Amling::R4P::Clumper::Key->new($key),
                };
            }

            return 1;
        }],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $bucket_wrapper = shift;

    return _wrap($os, $this->{'SPECS'}, 0, $bucket_wrapper, []);
}

sub _wrap
{
    my $os = shift;
    my $specs = shift;
    my $i = shift;
    my $bucket_wrapper = shift;
    my $bucket_pairs = shift;

    if($i == @$specs)
    {
        return $bucket_wrapper->($os, $bucket_pairs);
    }

    return $specs->[$i]->{'instance'}->wrap_stream($os, sub
    {
        my $os = shift;
        my $bucket_pairs0 = shift;

        return _wrap($os, $specs, $i + 1, $bucket_wrapper, [@$bucket_pairs, @$bucket_pairs0]);
    });
}

1;
