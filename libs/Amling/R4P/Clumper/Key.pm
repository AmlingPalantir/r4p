package Amling::R4P::Clumper::Key;

use strict;
use warnings;

use Amling::R4P::OutputStream::Easy;
use Amling::R4P::UnorderedSubstreams;
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

    my $substreams = Amling::R4P::UnorderedSubstreams->new($os);

    return Amling::R4P::OutputStream::Easy->new(
        $substreams,
        'BOF' => 'DROP',
        'LINE' => 'DECODE',
        'RECORD' => sub
        {
            my $r = shift;

            my $value = Amling::R4P::Utils::get_path($r, $key);
            my $bucket_stream = $bucket_streams->{$value};
            if(!defined($bucket_stream))
            {
                $bucket_stream = $substreams->next();
                $bucket_stream = $bucket_wrapper->($bucket_stream, [[$key, $value]]);
                $bucket_streams->{$value} = $bucket_stream;
            }

            $bucket_stream->write_record($r);
        },
        'CLOSE' => sub
        {
            for my $bucket_stream (values(%$bucket_streams))
            {
                $bucket_stream->close();
            }
        },
    );
}

sub names
{
    return ['k', 'key'];
}

1;
