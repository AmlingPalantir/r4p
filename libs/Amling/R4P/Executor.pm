package Amling::R4P::Executor;

use strict;
use warnings;

my $next_id = 0;

sub new
{
    my $class = shift;

    my $this =
    {
        'USES' => [],
    };

    bless $this, $class;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        [['M'], 1, $this->{'USES'}],
    ];
}

sub make_pkg
{
    my $this = shift;

    my $pkg = __PACKAGE__ . '::Hole' . $next_id++;

    for my $use (@{$this->{'USES'}})
    {
        eval "package $pkg; require $use; $use->import()";
        if($@)
        {
            die "Could not use $use: $@";
        }
    }

    return $pkg;
}

sub compile
{
    my $this = shift;
    my $pkg = shift;
    my $args = shift;
    my $body = shift;
    my $return = shift;

    my $code = "package $pkg; sub {";
    for my $arg (@$args)
    {
        $code .= " my \$$arg = shift;";
    }

    $code .= " $body;";

    if(defined($return))
    {
        $code .= " return \$$return;";
    }

    $code .= " }";

    my $sub;
    {
        no strict;
        no warnings;
        $sub = eval $code;
    }
    if($@)
    {
        die "Could not compile $body: $@";
    }

    return $sub;
}

1;
