package Amling::R4P::OutputStream::Hard;

use strict;
use warnings;

sub new
{
    my $class = shift;
    my %args = @_;

    my $this = {};

    for my $k ('WRITE_BOF', 'WRITE_RECORD', 'WRITE_LINE', 'CLOSE', 'RCLOSED')
    {
        $this->{$k} = delete $args{$k} || die "No $k specified?";
    }

    bless $this, $class;

    return $this;
}

sub write_bof
{
    return $_[0]->{'WRITE_BOF'}->(@_);
}

sub write_line
{
    return $_[0]->{'WRITE_LINE'}->(@_);
}

sub write_record
{
    return $_[0]->{'WRITE_RECORD'}->(@_);
}

sub close
{
    return $_[0]->{'CLOSE'}->(@_);
}

sub rclosed
{
    return $_[0]->{'RCLOSED'}->(@_);
}

1;
