package Amling::R4P::Sorter::Lexical;

use strict;
use warnings;

use Amling::R4P::Sorter::Base::OneKey;

use base ('Amling::R4P::Sorter::Base::OneKey');

sub cmp1
{
    my $this = shift;
    my $v1 = shift;
    my $v2 = shift;

    return ($v1 cmp $v2);
}

sub names
{
    return ['lexical', 'lex', 'l'];
}

1;
