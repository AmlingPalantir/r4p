package Amling::R4P::Operation::WithLines;

use strict;
use warnings;

use Amling::R4P::Operation::Base::WithSubOperation;
use Amling::R4P::OrderedSubstreams;
use Amling::R4P::OutputStream::Easy;
use Amling::R4P::OutputStream::SubsTransform;
use Amling::R4P::TwoRecordUnion;
use Amling::R4P::Utils;
use Clone ('clone');

use base ('Amling::R4P::Operation::Base::WithSubOperation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'TRU'} = Amling::R4P::TwoRecordUnion->new();
    $this->{'LINE_KEY'} = 'LINE';

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        @{$this->{'TRU'}->options()},
        [['lk', 'line-key'], 1, \$this->{'LINE_KEY'}],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;

    my $tru = $this->{'TRU'};
    my $line_key = $this->{'LINE_KEY'};

    my $substreams = Amling::R4P::OrderedSubstreams->new($os);

    return Amling::R4P::OutputStream::Easy->new(
        $substreams,
        'BOF' => 'DROP',
        'LINE' => 'DECODE',
        'RECORD' => sub
        {
            my $r1 = shift;

            my $line = Amling::R4P::Utils::get_path($r1, $line_key);

            my $os1 = $substreams->next();
            # Note that we pass lines as-is (rather than trying to parse as
            # JSON and joining).  Unclear if this is useful...
            $os1 = Amling::R4P::OutputStream::SubsTransform->new(
                $os1,
                'XFORM_RECORD' => sub
                {
                    my $r2 = shift;

                    return $tru->union(clone($r1), $r2);
                },
            );
            $os1 = $this->wrap_sub_stream($os1);
            $os1->write_line($line);
            $os1->close();
        },
    );
}

sub names
{
    return ['with-lines'];
}

1;
