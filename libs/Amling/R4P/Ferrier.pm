package Amling::R4P::Ferrier;

use strict;
use warnings;

sub new
{
    my $class = shift;

    my $this =
    {
        'READS' => [],
    };

    bless $this, $class;

    return $this;
}

sub register_read
{
    my $this = shift;
    my $pid = shift;
    my $in = shift;
    my $out = shift;

    push @{$this->{'READS'}}, [$pid, $in, $out, ''];
}

sub ferry
{
    my $this = shift;

    while(1)
    {
        # "take" reads.  In particular we need to be able to remove any that
        # finish and if some callback registers more reads we want to keep them
        # next round.
        my $old_reads = $this->{'READS'};
        my $reads = $this->{'READS'} = [];

        if(!@$old_reads)
        {
            return;
        }

        my $vec = '';
        for my $read (@$old_reads)
        {
            my ($pid, $in, $out, $buf) = @$read;
            vec($vec, fileno($in), 1) = 1;
        }
        select($vec, undef, undef, undef);

        for my $read (@$old_reads)
        {
            my ($pid, $in, $out, $buf) = @$read;
            if(!vec($vec, fileno($in), 1))
            {
                # no input
                push @$reads, [$pid, $in, $out, $buf];
                next;
            }

            my $chunk;
            my $len = sysread $in, $chunk, 1024;
            if(!$len)
            {
                # EOF
                waitpid $pid, 0 if(defined($pid));
                if($buf ne '')
                {
                    $out->write_line($buf);
                }
                $out->close();
                next;
            }

            $buf .= $chunk;
            my $start = 0;
            while(1)
            {
                my $i = index($buf, "\n", $start);
                if($i == -1)
                {
                    $buf = substr($buf, $start);
                    last;
                }
                $out->write_line(substr($buf, $start, ($i - $start)));
                $start = $i + 1;
            }
            push @$reads, [$pid, $in, $out, $buf];
        }
    }
}

1;
