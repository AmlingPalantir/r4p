package Amling::R4P::Operation::TopN;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Sort;
use Amling::R4P::OutputStream::Subs;

use base ('Amling::R4P::Operation::Base::Sort');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'COUNT'} = 10;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        [['ct', 'count'], 1, \$this->{'COUNT'}],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $ct = $this->{'COUNT'};

    my $pairs = [];

    my $prune = sub
    {
        @$pairs = sort { $this->cmp($a->[0], $b->[0]) || ($a->[1] <=> $b-0>[1]) } @$pairs;
        pop @$pairs while(@$pairs > $ct);
    };

    my $n = 0;
    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            push @$pairs, [$r, $n++];
            $prune->() if(@$pairs >= 2 * $ct);
        },
        'CLOSE' => sub
        {
            $prune->();
            for my $pair (@$pairs)
            {
                $os->write_record($pair->[0]);
            }
            $os->close();
        }
    );
}

sub names
{
    return ['top-n'];
}

1;
