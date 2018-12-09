package Amling::R4P::Operation::WithFiles;

use strict;
use warnings;

use Amling::R4P::Operation::Base::WithSubOperation;
use Amling::R4P::OrderedSubstreams;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::OutputStream::SubsTransform;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation::Base::WithSubOperation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'FILE_KEY'} = 'FILE';

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        [['fk', 'file-key'], 1, \$this->{'FILE_KEY'}],
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $file_key = $this->{'FILE_KEY'};

    my $ordered_streams = Amling::R4P::OrderedSubstreams->new($os);
    my $cur_os1 = undef;
    my $cur_file = undef;

    my $close_os1 = sub
    {
        return unless($cur_os1);

        $cur_os1->close();
        $cur_os1 = undef;
    };
    my $open_os1 = sub
    {
        my $file = shift;

        return if($cur_os1);

        my $os1 = $ordered_streams->next();
        # Note that we pass lines as-is (rather than trying to parse as JSON
        # and stamping).  Unclear if this is useful...
        $os1 = Amling::R4P::OutputStream::SubsTransform->new(
            $os1,
            'XFORM_RECORD' => sub
            {
                my $r = shift;

                Amling::R4P::Utils::set_path($r, $file_key, $file);

                return $r;
            },
        );
        $os1 = $this->wrap_sub_stream($os1, $fr);

        $cur_os1 = $os1;
    };

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_BOF' => sub
        {
            my $file = shift;

            $close_os1->();
            $open_os1->($file);
        },
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            $open_os1->(undef);
            $cur_os1->write_record($r);
        },
        'WRITE_LINE' => sub
        {
            my $line = shift;

            $open_os1->(undef);
            $cur_os1->write_line($line);
        },
        'CLOSE' => sub
        {
            $close_os1->();
            $ordered_streams->close();
        },
    );
}

sub names
{
    return ['with-files'];
}

1;
