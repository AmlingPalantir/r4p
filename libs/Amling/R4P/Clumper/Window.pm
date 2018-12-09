package Amling::R4P::Clumper::Window;

use strict;
use warnings;

use Amling::R4P::OutputStream::RefuseClose;
use Amling::R4P::OutputStream::Subs;
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

    my $os_no_close = Amling::R4P::OutputStream::RefuseClose->new($os);

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            push @$window, $r;
            if(@$window > $size)
            {
                shift @$window
            }
            if(@$window == $size)
            {
                my $os = $bucket_wrapper->($os_no_close, []);
                for my $r (@$window)
                {
                    # Ouch clone, but generally a record written to a stream
                    # should be considered lost and we may write to multiple
                    # streams.
                    $os->write_record(clone($r));
                }
                $os->close();
            }
        },
        'CLOSE' => sub
        {
            $os->close();
        },
    );
}

sub names
{
    return ['window'];
}

1;
