package Amling::R4P::TwoRecordUnion;

use strict;
use warnings;

use Amling::R4P::Utils;

sub new
{
    my $class = shift;

    my $this =
    {
        'LEFT_PREFIX' => undef,
        'RIGHT_PREFIX' => undef,
    };

    bless $this, $class;

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        [['lp', 'left-prefix'], 1, \$this->{'LEFT_PREFIX'}],
        [['rp', 'right-prefix'], 1, \$this->{'RIGHT_PREFIX'}],
    ];
}

sub union
{
    my $this = shift;
    my $r1 = shift;
    my $r2 = shift;

    my $r = {};

    for my $pair ([$this->{'LEFT_PREFIX'}, $r1], [$this->{'RIGHT_PREFIX'}, $r2])
    {
        my ($prefix, $re) = @$pair;
        next unless(defined($re));

        if(defined($prefix))
        {
            Amling::R4P::Utils::set_path($r, $prefix, $re);
        }
        else
        {
            $r = {%$r, %$re};
        }
    }

    return $r;
}

1;
