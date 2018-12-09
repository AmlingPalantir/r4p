package Amling::R4P::Operation::Chain;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Process;
use Amling::R4P::Registry;
use Amling::R4P::Utils;
use Getopt::Long;

use base ('Amling::R4P::Operation');

sub options
{
    my $this = shift;

    return
    [
        [undef], undef, sub
        {
            my $args = [@_];

            my $cmds = [];
            TOP: while(1)
            {
                my @cmd;
                while(1)
                {
                    if(!@$args)
                    {
                        push @$cmds, [@cmd];
                        last TOP;
                    }
                    my $arg = shift @$args;
                    if($arg eq '|')
                    {
                        push @$cmds, [@cmd];
                        next TOP;
                    }
                    push @cmd, $arg;
                }
            }

            my $wrappers = [];
            my $files = undef;
            for my $cmd (@$cmds)
            {
                my ($wrapper, $files1) = @{construct_stage_wrapper($cmd)};
                push @$wrappers, $wrapper;
                if(!defined($files))
                {
                    $files = $files1;
                }
                else
                {
                    die 'Non-initial chain stages must expect STDIN.' if(@$files1);
                }
            }

            $this->{'WRAPPERS'} = $wrappers;
            $this->extra_args($files);
        },

        @{$this->SUPER::options()},
    ];
}

sub validate
{
    my $this = shift;

    die 'No command?' unless($this->{'WRAPPERS'});

    return $this->SUPER::validate();
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    for my $wrapper (reverse(@{$this->{'WRAPPERS'}}))
    {
        $os = $wrapper->($os, $fr);
    }

    return $os;
}

sub names
{
    return ['chain'];
}

sub construct_stage_wrapper
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

        my $pos = Amling::R4P::OutputStream::Process->new($cmd);
        $fr->register($pos->pid(), $pos->in(), $os);
        return $pos;
    };
    # subprocess stages always get STDIN
    return [$wrapper, []];
}

1;
