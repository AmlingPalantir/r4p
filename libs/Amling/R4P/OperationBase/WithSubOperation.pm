package Amling::R4P::OperationBase::WithSubOperation;

use strict;
use warnings;

use Amling::R4P::Operation::Chain;
use Amling::R4P::Operation;

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
        [undef], undef, sub
        {
            my ($wrapper, $files) = @{Amling::R4P::Operation::Chain::construct_stage_wrapper([@_])};

            $this->{'WRAPPER'} = $wrapper;
            $this->extra_args($files);
        },

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

1;
