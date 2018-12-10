package Amling::R4P::Operation::Sort;

use strict;
use warnings;

use Amling::R4P::Operation::Base::Sort;
use Amling::R4P::OutputStream::Subs;

use base ('Amling::R4P::Operation::Base::Sort');

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
            for my $r (sort { $this->cmp($a, $b) } @$rs)
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
