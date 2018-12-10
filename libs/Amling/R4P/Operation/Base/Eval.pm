package Amling::R4P::Operation::Base::Eval;

use strict;
use warnings;

use Amling::R4P::Executor;
use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;
    my %args = @_;

    my $this = $class->SUPER::new();

    $this->{'EXECUTOR'} = Amling::R4P::Executor->new();
    $this->{'SEPARATE'} = 0;
    $this->{'INVERT'} = 0;
    $this->{'CODE'} = undef;

    for my $k ('INPUT', 'RETURN', 'OUTPUT')
    {
        $this->{$k} = delete($args{$k});
    }

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        [[undef], 1, \$this->{'CODE'}],

        @{$this->SUPER::options()},

        @{$this->{'EXECUTOR'}->options()},

        [['separate'], 0, \$this->{'SEPARATE'}],
        [['v', 'invert'], 0, \$this->{'INVERT'}],

        [['input-lines'], 0, sub { $this->{'INPUT'} = 'LINES'; return 0; }],
        [['input-records'], 0, sub { $this->{'INPUT'} = 'RECORDS'; return 0; }],

        [['return'], 0, sub { $this->{'RETURN'} = 1; return 0; }],
        [['no-return'], 0, sub { $this->{'RETURN'} = 0; return 0; }],

        [['output-lines'], 0, sub { $this->{'OUTPUT'} = 'LINES'; return 0; }],
        [['output-records'], 0, sub { $this->{'OUTPUT'} = 'RECORDS'; return 0; }],
        [['output-grep'], 0, sub { $this->{'OUTPUT'} = 'GREP'; return 0; }],
    ];
}

sub validate
{
    my $this = shift;

    my $code = $this->{'CODE'};
    die 'No code specified?' unless(defined($code));

    $code =~ s/\{\{(.*?)\}\}/Amling::R4P::Utils::generate_path_ref($1)/ge;

    my $executor = $this->{'EXECUTOR'};

    my $sub_supplier = sub
    {
        my $pkg = $executor->make_pkg();
        return $executor->compile($pkg, ['r'], $code, ($this->{'RETURN'} ? 'r' : undef));
    };
    if($this->{'SEPARATE'})
    {
        $this->{'SUB_SUPPLIER'} = $sub_supplier;
    }
    else
    {
        my $sub = $sub_supplier->();
        $this->{'SUB_SUPPLIER'} = sub { return $sub; };
    }

    return $this->SUPER::validate();
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $sub = $this->{'SUB_SUPPLIER'}->();
    my $invert = $this->{'INVERT'};

    my $input_event;
    my $pass_sub;
    my $input = $this->{'INPUT'};
    if($input eq 'LINES')
    {
        $input_event = 'WRITE_LINE';
        $pass_sub = sub { $os->write_line($_[0]); };
    }
    elsif($input eq 'RECORDS')
    {
        $input_event = 'WRITE_RECORD';
        $pass_sub = sub { $os->write_record($_[0]); };
    }
    else
    {
        die;
    }

    my $output_sub;
    my $output = $this->{'OUTPUT'};
    if($output eq 'LINES')
    {
        $output_sub = sub
        {
            my $vi = shift;
            my $vo = shift;

            $vo = Amling::R4P::Utils::pretty_string($vo);

            $os->write_line($vo);
        };
    }
    elsif($output eq 'RECORDS')
    {
        $output_sub = sub
        {
            my $vi = shift;
            my $vo = shift;

            _unpack_records($os, $vo);
        };
    }
    elsif($output eq 'GREP')
    {
        $output_sub = sub
        {
            my $vi = shift;
            my $vo = shift;

            return unless($vo);

            $pass_sub->($vi);
        };
    }
    else
    {
        die;
    }

    return Amling::R4P::OutputStream::Subs->new(
        $input_event => sub
        {
            my $vi = shift;

            my $vo = $sub->($vi);
            $vo = !$vo if($invert);

            $output_sub->($vi, $vo);
        },
        'CLOSE' => sub
        {
            $os->close();
        }
    );
}

sub _unpack_records
{
    my $os = shift;
    my $v = shift;

    if(UNIVERSAL::isa($v, 'HASH'))
    {
        $os->write_record($v);
        return;
    }

    if(UNIVERSAL::isa($v, 'ARRAY'))
    {
        for my $v2 (@$v)
        {
            _unpack_records($os, $v2);
        }
        return;
    }

    die;
}

1;
