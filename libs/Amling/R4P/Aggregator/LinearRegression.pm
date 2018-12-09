package Amling::R4P::Aggregator::LinearRegression;

use strict;
use warnings;

use Amling::R4P::Aggregator::Base::Ord2Bivariate;

use base ('Amling::R4P::Aggregator::Base::Ord2Bivariate');

sub finish1
{
    my $this = shift;
    my $s1 = shift;
    my $sx = shift;
    my $sy = shift;
    my $sxy = shift;
    my $sx2 = shift;
    my $sy2 = shift;

    my $beta = ($sxy * $s1 - $sx * $sy) / ($sx2 * $s1 - $sx ** 2);
    my $alpha = ($sy - $beta * $sx) / $s1;

    my $sbeta_numerator = ($sy2 + $alpha ** 2 * $s1 + $beta ** 2 * $sx2 - 2 * $alpha * $sy + 2 * $alpha * $beta * $sx - 2 * $beta * $sxy) / ($s1 - 2);
    my $sbeta_denominator = $sx2 - $sx * $sx / $s1;
    my $sbeta = sqrt($sbeta_numerator / $sbeta_denominator);
    my $salpha = $sbeta * sqrt($sx2 / $s1);

    return
    {
        'alpha' => $alpha,
        'beta' => $beta,
        'beta_se' => $sbeta,
        'alpha_se' => $salpha,
    };
}

sub names
{
    return ['linreg'];
}

1;
