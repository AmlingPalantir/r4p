package Amling::R4P::Registry;

use strict;
use warnings;

my %caches;

sub _cache
{
    my $base = shift;
    return $caches{$base} ||= _init($base);
}

sub list
{
    my $base = shift;

    return [keys(%{_cache($base)})];
}

sub impl
{
    my $base = shift;
    my $name = shift;

    return _cache($base)->{$name} || die "No $base named $name";
}

sub find_spec
{
    my $base = shift;
    my $spec = shift;

    my @args = split(/,/, $spec);
    die "No arguments for $base?" unless(@args);

    my $name = shift @args;
    my $impl = impl($base, $name);
    die "Wrong argument count for $base $name" unless($impl->argct() == @args);

    return $impl->new(@args);
}

sub find
{
    my $base = shift;
    my $name = shift;

    return impl($base, $name)->new();
}

sub pairs
{
    my $base = shift;

    my $cache = _cache($base);

    return [map { [$_, $cache->{$_}] } keys(%$cache)];
}

sub options
{
    my $base = shift;
    my $short_names = shift;
    my $long_names = shift;
    my $use_labels = shift;
    my $specs = shift;

    my $ret =
    [
        [$short_names, 1, sub
        {
            my $arg = shift;

            my $label = undef;
            $label = $1 if($use_labels && $arg =~ s/^([^=]*)=//);

            my $spec =
            {
                'arg' => $arg,
                'instance' => find_spec($base, $arg),
            };

            $spec->{'label'} = $label if($use_labels);

            push @$specs, $spec;

            return 1;
        }],
    ];

    for my $pair (@{pairs($base)})
    {
        my ($name, $impl) = @$pair;
        my $argct = $impl->argct();

        push @$ret,
        (
            [[map { "$_-$name" } @$long_names], ($argct + ($use_labels ? 1 : 0)), sub
            {
                my $label = undef;
                $label = shift if($use_labels);
                my $args = [@_];

                my $spec =
                {
                    'arg' => join(',', @$args),
                    'instance' => $impl->new(@$args),
                };

                $spec->{'label'} = $label if($use_labels);

                push @$specs, $spec;

                return 1;
            }],
        );
    }

    return $ret;
}

sub _init
{
    my $base = shift;

    my $cache = {};
    for my $inc (@INC)
    {
        my $path = $inc . "/" . _slash($base);
        if(-d $path)
        {
            opendir(DIR, $path) || die "Could not opendir $path: $!";
            for my $e (readdir(DIR))
            {
                if($e =~ /^(.*)\.pm$/)
                {
                    my $module = $1;
                    require(_slash($base) . "/$module.pm");
                    my $impl = "${base}::$module";
                    for my $name (@{$impl->names()})
                    {
                        my $already = $cache->{$name};
                        if(defined($already))
                        {
                            die "Collision for $name in $base between $already and $impl";
                        }
                        $cache->{$name} = $impl;
                    }
                }
            }
            closedir(DIR) || die "Could not closedir $path: $!";
        }
    }

    return $cache;
}

sub _slash
{
    my $s = shift;
    $s =~ s@::@/@g;
    return $s;
}

1;
