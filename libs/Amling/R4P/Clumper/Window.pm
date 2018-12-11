package Amling::R4P::Clumper::Window;

use strict;
use warnings;

use Amling::R4P::OrderedSubstreams;
use Amling::R4P::OutputStream::Easy;
use Clone ('clone');

sub new
{
    my $class = shift;
    my $size = shift;

    my $this =
    {
        'SIZE' => $size,
    };

    bless $this, $class;

    return $this;
}

sub argct
{
    return 1;
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $bucket_wrapper = shift;

    my $size = $this->{'SIZE'};
    my $window = [];

    my $substreams = Amling::R4P::OrderedSubstreams->new($os);

    return Amling::R4P::OutputStream::Easy->new(
        $substreams,
        'BOF' => 'DROP',
        'LINE' => 'DECODE',
        'RECORD' => sub
        {
            my $r = shift;

            push @$window, $r;
            if(@$window > $size)
            {
                shift @$window
            }
            if(@$window == $size)
            {
                my $os1 = $substreams->next();
                $os1 = $bucket_wrapper->($os1, []);
                for my $r (@$window)
                {
                    # Ouch clone, but generally a record written to a stream
                    # should be considered lost and we may write to multiple
                    # streams.
                    $os1->write_record(clone($r));
                }
                $os1->close();
            }
        },
    );
}

sub names
{
    return ['window'];
}

1;
