package Amling::R4P::Operation::Collate;

use strict;
use warnings;

use Amling::R4P::Clump;
use Amling::R4P::Operation::Aggregate;
use Amling::R4P::OutputStream::StampPaths;

use base ('Amling::R4P::Operation::Aggregate');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'CLUMP'} = Amling::R4P::Clump->new();

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        @{$this->{'CLUMP'}->options()},
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;

    return $this->{'CLUMP'}->wrap_stream($os, sub
    {
        my $os = shift;
        my $bucket_pairs = shift;

        $os = Amling::R4P::OutputStream::StampPaths->new($os, $bucket_pairs);
        $os = $this->SUPER::wrap_stream($os);

        return $os;
    });
}

sub names
{
    return ['collate'];
}

1;
