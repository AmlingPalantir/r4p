package Amling::R4P::Operation::FromLines;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'LINE_KEY'} = 'LINE';
    $this->{'LINENO_KEY'} = 'LINENO';
    $this->{'FILE_KEY'} = 'FILE';

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        [['lk', 'line-key'], 1, \$this->{'LINE_KEY'}],
        [['lnk', 'lineno-key'], 1, \$this->{'LINENO_KEY'}],
        [['fk', 'file-key'], 1, \$this->{'FILE_KEY'}],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $line_key = $this->{'LINE_KEY'};
    my $lineno_key = $this->{'LINENO_KEY'};
    my $file_key = $this->{'FILE_KEY'};

    my $cur_file = undef;
    my $cur_lineno = 1;

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_BOF' => sub
        {
            my $file = shift;

            $cur_file = $file;
            $cur_lineno = 1;
        },
        'WRITE_LINE' => sub
        {
            my $line = shift;

            my $r =
            {
                $line_key => $line,
                $lineno_key => $cur_lineno++,
                $file_key => $cur_file,
            };
            $os->write_record($r);
        },
        'CLOSE' => sub
        {
            $os->close();
        }
    );
}

sub names
{
    return ['from-lines'];
}

1;
