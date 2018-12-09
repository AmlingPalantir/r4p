package Amling::R4P::Operation::Join;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::TwoRecordUnion;
use Amling::R4P::Utils;
use Clone ('clone');
use JSON;

use base ('Amling::R4P::Operation');

my $json = JSON->new();

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'TRU'} = Amling::R4P::TwoRecordUnion->new();
    $this->{'FILLS'} = [0, 0];
    $this->{'PAIRS'} = [];
    $this->{'DB_FILE'} = undef;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        [undef], 1, \$this->{'DB_FILE'},

        @{$this->SUPER::options()},

        @{$this->{'TRU'}->options()},
        ['on'], 1, $this->{'PAIRS'},
        ['inner'], 0, sub { $this->{'FILLS'} = [0, 0]; },
        ['left'], 0, sub { $this->{'FILLS'} = [1, 0]; },
        ['right'], 0, sub { $this->{'FILLS'} = [0, 1]; },
        ['outer'], 0, sub { $this->{'FILLS'} = [1, 1]; },
    ];
}

sub validate
{
    my $this = shift;

    my $db_file = $this->{'DB_FILE'};
    die 'No LHS specified for join?' unless(defined($db_file));

    my $lhs_keys = [];
    my $rhs_keys = [];
    for my $pair (@{$this->{'PAIRS'}})
    {
        if($pair =~ /^(.*),(.*)$/)
        {
            push @$lhs_keys, $1;
            push @$rhs_keys, $2;
        }
        else
        {
            push @$lhs_keys, $pair;
            push @$rhs_keys, $pair;
        }
    }
    $this->{'RHS_KEYS'} = $rhs_keys;

    my $db = undef;

    open(my $fh, '<', $db_file) || die "Could not open $db_file: $!";
    while(my $line = <$fh>)
    {
        chomp $line;
        my $r = $json->decode($line);

        my $p = \$db;
        for my $k (@$lhs_keys)
        {
            my $v = Amling::R4P::Utils::get_path($r, $k);
            $p = \(($$p ||= {})->{$v});
        }

        $$p ||= [0, []];
        push @{$$p->[1]}, $r;
    }
    close($fh) || die "Could not close $db_file: $!";

    $this->{'DB'} = $db;

    return $this->SUPER::validate();
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $tru = $this->{'TRU'};
    my ($fill_left, $fill_right) = @{$this->{'FILLS'}};
    my $rhs_keys = $this->{'RHS_KEYS'};
    my $db = $this->{'DB'};

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r1 = shift;

            my $p = $db;
            for my $k (@$rhs_keys)
            {
                my $v = Amling::R4P::Utils::get_path($r1, $k);
                $p = ($p || {})->{$v};
            }
            $p ||= [0, []];
            $p->[0] = 1;
            my $r2s = $p->[1];

            if($fill_left && !@$r2s)
            {
                $r2s = [undef];
            }

            for my $r2 (@$r2s)
            {
                my $r1c = (@$p == 1) ? $r1 : clone($r1);
                $os->write_record($tru->union(clone($r2), $r1c));
            }
        },
        'CLOSE' => sub
        {
            if($fill_right)
            {
                _fill_right($os, $tru, $db, scalar(@$rhs_keys));
            }
            $os->close();
        }
    );
}

sub _fill_right
{
    my $os = shift;
    my $tru = shift;
    my $db = shift;
    my $depth = shift;

    if(!$depth)
    {
        return if($db->[0]);
        for my $r2 (@{$db->[1]})
        {
            $os->write_record($tru->union($r2, undef));
        }
        return;
    }

    for my $db2 (values(%$db))
    {
        _fill_right($os, $tru, $db2, $depth - 1);
    }
}

sub names
{
    return ['join'];
}

1;
