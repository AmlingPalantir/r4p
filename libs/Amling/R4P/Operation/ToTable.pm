package Amling::R4P::Operation::ToTable;

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

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        [['k', 'key'], 1, sub { push @{$this->{'KEYS'}}, split(/,/, $_[0]); }],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $keys = $this->{'KEYS'};

    my $rs = [];
    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            push @$rs, $r;
        },
        'CLOSE' => sub
        {
            if(@$keys == 0)
            {
                my $key_1 = {map { $_ => 1 } @$keys};

                for my $r (@$rs)
                {
                    for my $k (sort(keys(%$r)))
                    {
                        next if($key_1->{$k});
                        $key_1->{$k} = 1;
                        push @$keys, $k;
                    }
                }
            }

            my $rows = [];

            push @$rows, [map { [$_, ' '] } @$keys];
            push @$rows, [map { ['', '-'] } @$keys];
            for my $r (@$rs)
            {
                my $row = [];
                for(my $i = 0; $i < @$keys; ++$i)
                {
                    my $k = $keys->[$i];
                    my $v = undef;
                    if(Amling::R4P::Utils::has_path($r, $k))
                    {
                        $v = Amling::R4P::Utils::get_path($r, $k);
                    }

                    $v = Amling::R4P::Utils::pretty_string($v);

                    push @$row, [$v, ' '];
                }
                push @$rows, $row;
            }

            my $widths = [map { length($_) } @$keys];
            for my $row (@$rows)
            {
                for(my $i = 0; $i < @$keys; ++$i)
                {
                    my $v = $row->[$i]->[0];
                    if(length($v) > $widths->[$i])
                    {
                        $widths->[$i] = length($v);
                    }
                }
            }

            my $pad = sub
            {
                my $v = shift;
                my $w = shift;
                my $p = shift;

                return ($v . ($p x ($w - length($v))));
            };

            for my $row (@$rows)
            {
                my @line;
                for(my $i = 0; $i < @$keys; ++$i)
                {
                    if($i > 0)
                    {
                        push @line, '   ';
                    }
                    my ($v, $padc) = @{$row->[$i]};
                    push @line, $pad->($v, $widths->[$i], $padc);
                }
                $os->write_line(join('', @line));
            }

            $os->close();
        }
    );
}

sub names
{
    return ['to-table'];
}

1;
