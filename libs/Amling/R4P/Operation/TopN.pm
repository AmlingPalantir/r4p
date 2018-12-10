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
        $this->_fix_cut($pairs, 0, $ct, scalar(@$pairs));
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
            $prune->() if(@$pairs > $ct);
            for my $r (sort { $this->cmp($a, $b) } map { $_->[0] } @$pairs)
            {
                $os->write_record($r);
            }
            $os->close();
        }
    );
}

sub _fix_cut
{
    my $this = shift;
    my $pairs = shift;
    my $s = shift;
    my $t = shift;
    my $e = shift;

    my $cmp = sub
    {
        my $p1 = shift;
        my $p2 = shift;

        my $ret = ($this->cmp($p1->[0], $p2->[0]) || ($p1->[1] <=> $p2->[1]));
        return $ret;
    };

    my $swap = sub
    {
        my $i = shift;
        my $j = shift;
        return if($i == $j);
        ($pairs->[$i], $pairs->[$j]) = ($pairs->[$j], $pairs->[$i]);
    };

    while(1)
    {
        return if($t <= $s || $t >= $e);
        return if($e - $s <= 1);

        my $pi = $s + int(rand() * ($e - $s));
        $swap->($pi, $s);
        my $p = $pairs->[$s];
        my $front_end = $s + 1;
        my $back_start = $e;
        while(1)
        {
            # loop invariant:
            # $s is pivot
            # [$s + 1, $front_end) are all < pivot
            # [$back_start, $e) are all > pivot

            last if($front_end == $back_start);

            my $c = $cmp->($p, $pairs->[$front_end]);
            if($c < 0)
            {
                # > pivot
                --$back_start;
                $swap->($front_end, $back_start);
                next;
            }
            if($c > 0)
            {
                # < pivot
                ++$front_end;
                next;
            }
            die;
        }

        # done, swap pivot to middle
        --$front_end;
        $swap->($front_end, $s);

        if($t <= $front_end)
        {
            $e = $front_end;
            next;
        }

        if($t >= $back_start)
        {
            $s = $back_start;
            next;
        }

        return;
    }
}

sub names
{
    return ['top-n'];
}

1;
