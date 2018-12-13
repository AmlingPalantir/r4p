package Amling::R4P::Operation::Sort;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Sort;
use Amling::R4P::OutputStream::Easy;

use base ('Amling::R4P::Operation::Base::Sort');

sub wrap_stream
{
    my $this = shift;
    my $os = shift;

    my $rs = [];
    return Amling::R4P::OutputStream::Easy->new(
        $os,
        'BOF' => 'DROP',
        'LINE' => 'DECODE',
        'RECORD' => sub
        {
            my $r = shift;

            push @$rs, $r;
        },
        'CLOSE' => sub
        {
            for my $r (sort { $this->cmp($a, $b) } @$rs)
            {
                $os->write_record($r);
            }
        },
    );
}

sub names
{
    return ['sort'];
}

1;
