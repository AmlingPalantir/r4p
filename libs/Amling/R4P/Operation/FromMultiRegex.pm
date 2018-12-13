package Amling::R4P::Operation::FromMultiRegex;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Easy;
use Amling::R4P::Utils;
use Clone ('clone');

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'TUPLES'} = [];

    $this->{'KEEP'} = {};
    $this->{'KEEP_ALL'} = 0;

    $this->{'CLOBBER'} = 0;

    return $this;
}

sub _parse_regex
{
    my $arg = shift;

    die 'Must specify keys.' unless($arg =~ /^([^=]*)=(.*)$/);
    my ($keys, $re) = ($1, $2);

    return ([split(/,/, $keys)], $re);
}

sub options
{
    my $this = shift;

    my $tuples = $this->{'TUPLES'};

    return
    [
        @{$this->SUPER::options()},

        [['re'], 1, sub { push @$tuples, [0, 0, _parse_regex($_[0])]; }],
        [['pre'], 1, sub { push @$tuples, [1, 0, _parse_regex($_[0])]; }],
        [['post'], 1, sub { push @$tuples, [0, 1, _parse_regex($_[0])]; }],

        [['keep'], 1, sub { $this->{'KEEP'}->{$_} = 1 for(split(/,/, $_[0])); }],
        [['keep-all'], 0, \$this->{'KEEP_ALL'}],

        [['clobber'], 0, \$this->{'CLOBBER'}],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;

    my $tuples = $this->{'TUPLES'};

    my $keep = $this->{'KEEP'};
    my $keep_all = $this->{'KEEP_ALL'};

    my $clobber = $this->{'CLOBBER'};

    my $r = {};
    my $flush = sub
    {
        if(%$r)
        {
            $os->write_record(clone($r));
        }

        return if($keep_all);

        my $r2 = {};
        for my $path (keys(%$keep))
        {
            if(Amling::R4P::Utils::has_path($r, $path))
            {
                my $v = Amling::R4P::Utils::get_path($r, $path);
                Amling::R4P::Utils::set_path($r2, $path, $v);
            }
        }
        $r = $r2;
    };
    return Amling::R4P::OutputStream::Easy->new(
        $os,
        'BOF' => sub
        {
            my $file = shift;

            if(!$clobber)
            {
                $flush->();
            }
            $r = {};

            $os->write_bof($file);
        },
        'LINE' => sub
        {
            my $line = shift;

            for my $tuple (@$tuples)
            {
                my ($pre_flush, $post_flush, $keys, $regex) = @$tuple;

                if(my @groups = ($line =~ $regex))
                {
                    if(!$clobber)
                    {
                        for(my $i = 0; $i < @groups && $i < @$keys; ++$i)
                        {
                            if(Amling::R4P::Utils::has_path($r, $keys->[$i]))
                            {
                                $pre_flush = 1;
                                last;
                            }
                        }
                    }
                    if($pre_flush)
                    {
                        $flush->();
                    }
                    for(my $i = 0; $i < @groups && $i < @$keys; ++$i)
                    {
                        Amling::R4P::Utils::set_path($r, $keys->[$i], $groups[$i]);
                    }
                    if($post_flush)
                    {
                        $flush->();
                    }
                }
            }
        },
        'RECORD' => 'ENCODE',
        'CLOSE' => sub
        {
            if(!$clobber)
            {
                $flush->();
            }
        },
    );
}

sub names
{
    return ['from-multire'];
}

1;
