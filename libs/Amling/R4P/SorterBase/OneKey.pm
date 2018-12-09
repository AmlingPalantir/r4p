package Amling::R4P::SorterBase::OneKey;

use strict;
use warnings;

use Amling::R4P::Utils;

sub new
{
    my $class = shift;
    my $key = shift;

    my $this =
    {
        'KEY' => $key,
    };

    bless $this, $class;

    return $this;
}

sub cmp
{
    my $this = shift;
    my $r1 = shift;
    my $r2 = shift;

    my $key = $this->{'KEY'};
    if($key =~ s/^-//)
    {
        ($r1, $r2) = ($r2, $r1);
    }

    my $v1 = Amling::R4P::Utils::get_path($r1, $key);
    my $v2 = Amling::R4P::Utils::get_path($r2, $key);

    return $this->cmp1($v1, $v2);
}

sub argct
{
    return 1;
}

1;
