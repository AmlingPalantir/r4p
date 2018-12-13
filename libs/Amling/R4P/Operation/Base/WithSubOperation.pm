package Amling::R4P::Operation::Base::WithSubOperation;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Process;
use Amling::R4P::Registry;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'WRAPPER'} = undef;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        [[undef], undef, sub
        {
            my ($wrapper, $files) = @{construct_wrapper([@_])};

            $this->{'WRAPPER'} = $wrapper;
            $this->extra_args($files);

            return 0;
        }],

        @{$this->SUPER::options()},
    ];
}

sub validate
{
    my $this = shift;

    die 'No suboperation provided?' unless($this->{'WRAPPER'});

    return $this->SUPER::validate();
}

sub wrap_sub_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    return $this->{'WRAPPER'}->($os, $fr);
}

sub construct_wrapper
{
    my $cmd = shift;

    die 'Empty command?' unless(@$cmd);

    if($cmd->[0] =~ /^r4p-(.*)$/)
    {
        my $op = Amling::R4P::Registry::find('Amling::R4P::Operation', $1);

        my $args = [@$cmd];
        shift @$args;
        Amling::R4P::Utils::parse_options($op->options(), $args);
        my $files = $op->validate();

        my $wrapper = sub
        {
            my $os = shift;
            my $fr = shift;

            return $op->wrap_stream($os, $fr);
        };

        return [$wrapper, $files];
    }

    my $wrapper = sub
    {
        my $os = shift;
        my $fr = shift;

        return Amling::R4P::OutputStream::Process->new($os, $cmd);
    };
    # subprocess stages always get STDIN
    return [$wrapper, []];
}


1;
