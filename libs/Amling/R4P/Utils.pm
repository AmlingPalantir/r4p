package Amling::R4P::Utils;

use strict;
use warnings;

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

    for(my $i = 0; $i < @$options; $i += 3)
    {
        my $aliases = $options->[$i];
        my $count = $options->[$i + 1];
        my $target = [$count, _convert_target($count, $options->[$i + 2])];

        for my $alias (@$aliases)
        {
            my $p;
            if(!defined($alias))
            {
                push @$catchalls, $target;
                next;
            }

            if(length($alias) == 1)
            {
                $p = \$captures->{"-$alias"};
            }
            else
            {
                $p = \$captures->{"--$alias"};
            }

            if(defined($$p))
            {
                die "Two captures for $alias?";
            }
            $$p = $target;
        }
    }

    $args = [@$args];
    while(@$args)
    {
        my $arg = $args->[0];
        my $target = $captures->{$arg};
        if(defined($target))
        {
            shift @$args;
        }
        else
        {
            $target = shift @$catchalls;
            if(!defined($target))
            {
                die "Unknown option: $arg";
            }
        }

        my $argct = $target->[0];
        if(defined($argct))
        {
            die "Not enough arguments left at $arg" if($argct > @$args);
            $target->[1]->(splice @$args, 0, $argct);
        }
        else
        {
            $target->[1]->(splice @$args, 0);
        }
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
            return sub { $$target = 1; };
        }
        if(defined($count) && $count == 1)
        {
            return sub { $$target = shift; };
        }
        die 'Nonsense count for scalar option';
    }

    if(ref($target) eq 'ARRAY')
    {
        if(defined($count) && $count == 0)
        {
            die 'Count 0 with array option makes no sense';
        }
        return sub { push @$target, @_; };
    }

    if(ref($target) eq 'CODE')
    {
        return $target;
    }

    die 'Unexpected target?';
}

1;
