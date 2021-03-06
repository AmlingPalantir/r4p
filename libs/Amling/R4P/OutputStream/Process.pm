package Amling::R4P::OutputStream::Process;

use strict;
use warnings;

use IPC::Open2;
use JSON;

my $json = JSON->new();

sub new
{
    my $class = shift;
    my $os = shift;
    my $cmd = shift;

    my $this = {};

    $this->{'DELEGATE'} = $os;

    my $in;
    my $out;
    my $pid = open2($in, $out, 'env', @$cmd);

    $this->{'IN'} = $in;
    $this->{'OUT'} = $out;
    $this->{'PID'} = $pid;

    bless $this, $class;

    return $this;
}

sub write_bof
{
}

sub write_record
{
    my $this = shift;
    my $r = shift;

    $this->ferry($json->encode($r) . "\n", 0);
}

sub write_line
{
    my $this = shift;
    my $line = shift;

    $this->ferry("$line\n", 0);
}

sub close
{
    my $this = shift;

    my $out = $this->{'OUT'};
    if(defined($out))
    {
        CORE::close($out);
        $this->{'OUT'} = undef;
    }

    $this->ferry('', 1);

    waitpid $this->{'PID'}, 0;
}

sub ferry
{
    my $this = shift;
    my $pending_out = shift;
    my $wait_for_end = shift;

    my $os = $this->{'DELEGATE'};

    while(1)
    {
        my $in = $this->{'IN'};
        my $out = $this->{'OUT'};

        my $hang = 0;
        my $vec_read = '';
        my $vec_write = '';
        if(defined($in))
        {
            vec($vec_read, fileno($in), 1) = 1;
            if($wait_for_end)
            {
                $hang = 1;
            }
        }
        if(defined($out))
        {
            if($pending_out)
            {
                vec($vec_write, fileno($out), 1) = 1;
                $hang = 1;
            }
        }
        else
        {
            $pending_out = '';
        }

        select($vec_read, $vec_write, undef, ($hang ? undef : 0));

        my $progress = 0;
        if(defined($in) && vec($vec_read, fileno($in), 1))
        {
            $progress = 1;

            my $buf = $this->{'BUF'};

            my $chunk;
            my $len = sysread $in, $chunk, 1024;
            my $closed = 0;
            if($len)
            {
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
                    $os->write_line(substr($buf, $start, ($i - $start)));
                    if($os->rclosed())
                    {
                        $closed = 1;
                        $buf = '';
                        last;
                    }
                    $start = $i + 1;
                }
                $this->{'BUF'} = $buf;
            }
            else
            {
                if($buf ne '')
                {
                    $os->write_line($buf);
                }
                $closed = 1;
            }
            if($closed)
            {
                CORE::close($in);
                $os->close();
                $this->{'IN'} = undef;
            }
        }
        if(defined($out) && vec($vec_write, fileno($out), 1))
        {
            $progress = 1;

            my $len;
            {
                local $SIG{'PIPE'} = 'IGNORE';
                $len = syswrite $out, $pending_out;
            }

            if(defined($len))
            {
                $pending_out = substr($pending_out, $len);
            }
            else
            {
                $this->{'OUT'} = undef;
                $pending_out = '';
            }
        }

        next if($progress || $hang);
        last;
    }
}

sub rclosed
{
    my $this = shift;

    return !defined($this->{'OUT'});
}

1;
