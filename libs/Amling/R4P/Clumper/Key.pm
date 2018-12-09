package Amling::R4P::Clumper::Key;

use strict;
use warnings;

use Amling::R4P::OutputStream::RefuseClose;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Utils;

sub new
{
    my $class = shift;
    my $key = shift;

    my $this =
    {
        'KEY' => $key,
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

    my $key = $this->{'KEY'};
    my $bucket_streams = {};

    my $os_no_close = Amling::R4P::OutputStream::RefuseClose->new($os);

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            my $value = Amling::R4P::Utils::get_path($r, $key);
            my $bucket_stream = $bucket_streams->{$value};
            if(!defined($bucket_stream))
            {
                $bucket_stream = $bucket_streams->{$value} = $bucket_wrapper->($os_no_close, [[$key, $value]]);
            }

            $bucket_stream->write_record($r);
        },
        'CLOSE' => sub
        {
            for my $bucket_stream (values(%$bucket_streams))
            {
                $bucket_stream->close();
            }
            $os->close();
        },
    );
}

sub names
{
    return ['k', 'key'];
}

1;
