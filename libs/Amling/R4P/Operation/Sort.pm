package Amling::R4P::Operation::Sort;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Registry;
use Amling::R4P::Sorter::Lexical;
use Amling::R4P::Sorter::Numeric;

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

    my $ret =
    [
        @{$this->SUPER::options()},

        @{Amling::R4P::Registry::options('Amling::R4P::Sorter', ['s', 'sorter'], [], 0, $specs)},
    ];

    for my $class ('Amling::R4P::Sorter::Lexical', 'Amling::R4P::Sorter::Numeric')
    {
        push @$ret,
        (
            [$class->names(), 1, sub
            {
                for my $key (split(',', $_[0]))
                {
                    push @$specs,
                    {
                        'instance' => $class->new($key),
                    };
                }
            }],
        );
    }

    return $ret;
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $rs = [];
    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            push @$rs, $r;
        },
        'CLOSE' => sub
        {
            my $sorters = [map { $_->{'instance'} } @{$this->{'SPECS'}}];

            my $cmp = sub
            {
                my $r1 = shift;
                my $r2 = shift;

                for my $sorter (@$sorters)
                {
                    my $r = $sorter->cmp($r1, $r2);
                    return $r if($r != 0);
                }

                return 0;
            };

            for my $r (sort { $cmp->($a, $b) } @$rs)
            {
                $os->write_record($r);
            }
            $os->close();
        }
    );
}

sub names
{
    return ['sort'];
}

1;
