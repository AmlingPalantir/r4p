package Amling::R4P::Utils;

use strict;
use warnings;

use JSON;

my $json = JSON->new();

sub _get_path_ptr
{
    my $r = shift;
    my $path = shift;

    my $p = \$r;

    for my $step (split(m@/@, $path))
    {
        if($step =~ /^#(.*)$/)
        {
            $p = \(($$p ||= [])->[$1]);
            next;
        }
        $p = \(($$p ||= {})->{$step});
    }

    return $p;
}

sub has_path
{
    my $r = shift;
    my $path = shift;

    my $p = $r;

    for my $step (split(m@/@, $path))
    {
        if($step =~ /^#(.*)$/)
        {
            my $i = $1;
            return 0 unless($i < @$p);
            $p = $p->[$i];
            next;
        }
        return 0 unless(exists($p->{$step}));
        $p = $p->{$step};
    }

    return 1;
}

sub generate_path_ref
{
    my $path = shift;

    my @pieces = ('$r');

    for my $step (split(m@/@, $path))
    {
        if($step =~ /^#(.*)$/)
        {
            push @pieces, "->[$1]";
            next;
        }
        push @pieces, "->{q{$step}}";
    }

    return join('', @pieces);
}

sub get_path
{
    my $r = shift;
    my $path = shift;

    return ${_get_path_ptr($r, $path)};
}

sub set_path
{
    my $r = shift;
    my $path = shift;
    my $value = shift;

    ${_get_path_ptr($r, $path)} = $value;
}

sub parse_options
{
    my $options = shift;
    my $args = shift;

    my $captures = {};
    my $catchalls = [];

    for my $tuple (@$options)
    {
        my ($aliases, $count, $target) = @$tuple;
        $target = [1, $count, _convert_target($count, $target)];

        for my $alias (@$aliases)
        {
            if(!defined($alias))
            {
                push @$catchalls, $target;
                next;
            }

            if($captures->{$alias})
            {
                die "Two captures for $alias?";
            }
            $captures->{$alias} = $target;
        }
    }

    $args = [@$args];
    my $force_catchall = 0;
    while(@$args)
    {
        my $arg = $args->[0];

        if(!$force_catchall && $arg eq '--')
        {
            shift @$args;
            $force_catchall = 1;
            next;
        }

        my $target;
        if(!$force_catchall && $arg =~ /^-+(.*)$/)
        {
            my $alias = $1;
            shift @$args;
            $target = $captures->{$alias};
        }
        else
        {
            for my $catchall (@$catchalls)
            {
                if($catchall->[0])
                {
                    $target = $catchall;
                    last;
                }
            }
        }

        die "Unknown option at $arg" unless(defined($target));
        die "Unexpected repeat at $arg" unless($target->[0]);

        my $argct = $target->[1];
        my @args1;
        if(defined($argct))
        {
            die "Not enough arguments left at $arg" if($argct > @$args);
            @args1 = splice @$args, 0, $argct;
        }
        else
        {
            @args1 = splice @$args, 0;
        }
        $target->[0] = $target->[2]->(@args1);
    }
}

sub _convert_target
{
    my $count = shift;
    my $target = shift;

    if(ref($target) eq 'SCALAR')
    {
        if(defined($count) && $count == 0)
        {
            return sub { $$target = 1; return 0; };
        }
        if(defined($count) && $count == 1)
        {
            return sub { $$target = shift; return 0; };
        }
        die 'Nonsense count for scalar option';
    }

    if(ref($target) eq 'ARRAY')
    {
        if(defined($count) && $count == 0)
        {
            die 'Count 0 with array option makes no sense';
        }
        return sub { push @$target, @_; return 1; };
    }

    if(ref($target) eq 'HASH')
    {
        if(defined($count) && $count == 2)
        {
            return sub { $target->{$_[0]} = $_[1]; return 1; };
        }
    }

    if(ref($target) eq 'CODE')
    {
        return $target;
    }

    die 'Unexpected target?';
}

sub pretty_string
{
    my $v = shift;
    if(!defined($v))
    {
        $v = '';
    }
    if(ref($v) ne '')
    {
        $v = $json->encode($v);
    }
    return $v;
}

1;
