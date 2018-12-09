package Amling::R4P::OutputStream::SubsTransform;

use strict;
use warnings;

use Amling::R4P::OutputStream::Subs;

use base ('Amling::R4P::OutputStream::Subs');

sub new
{
    my $class = shift;
    my $os = shift;
    my %args = @_;

    my $xform_line = $args{'XFORM_LINE'};
    my $xform_record = $args{'XFORM_RECORD'};

    return $class->SUPER::new(
        'WRITE_LINE' => sub
        {
            my $line = shift;
            $line = $xform_line->($line) if($xform_line);
            $os->write_line($line);
        },
        'WRITE_RECORD' => sub
        {
            my $r = shift;
            $r = $xform_record->($r) if($xform_record);
            $os->write_record($r);
        },
        'CLOSE' => sub
        {
            $os->close();
        },
    );
}

1;
