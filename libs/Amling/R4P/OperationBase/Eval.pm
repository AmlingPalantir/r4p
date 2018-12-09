package Amling::R4P::OperationBase::Eval;

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

    my $this = $class->SUPER::new();

    $this->{'EXECUTOR'} = Amling::R4P::Executor->new();
    $this->{'SEPARATE'} = 0;
    $this->{'CODE'} = undef;

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
        return $executor->compile($pkg, ['r'], $code, $this->return());
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

    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            my $v = $sub->($r);

            $this->on_value($os, $v, $r);
        },
        'CLOSE' => sub
        {
            $os->close();
        }
    );
}

sub return
{
    return undef;
}

1;
