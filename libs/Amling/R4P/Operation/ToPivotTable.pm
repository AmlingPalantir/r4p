package Amling::R4P::Operation::ToPivotTable;

use strict;
use warnings;

use Amling::R4P::Operation;
use Amling::R4P::OutputStream::Subs;
use Amling::R4P::Registry;
use Amling::R4P::Utils;

use base ('Amling::R4P::Operation');

sub new
{
    my $class = shift;

    my $this = $class->SUPER::new();

    $this->{'X_KEYS'} = [];
    $this->{'Y_KEYS'} = [];
    $this->{'PINS'} = {};
    $this->{'V_KEYS'} = [];
    $this->{'X_SORTS'} = [];
    $this->{'Y_SORTS'} = [];

    return $this;
}

sub options
{
    my $this = shift;

    return
    [
        @{$this->SUPER::options()},

        [['x'], 1, $this->{'X_KEYS'}],
        [['y'], 1, $this->{'Y_KEYS'}],
        [['p'], 2, $this->{'PINS'}],
        [['v'], 1, $this->{'V_KEYS'}],

        @{Amling::R4P::Registry::options('Amling::R4P::Sorter', ['xs', 'x-sorter'], [], 0, $this->{'X_SORTS'})},
        @{Amling::R4P::Registry::options('Amling::R4P::Sorter', ['ys', 'y-sorter'], [], 0, $this->{'Y_SORTS'})},
    ];
}

sub wrap_stream
{
    my $this = shift;
    my $os = shift;
    my $fr = shift;

    my $rs = [];
    return Amling::R4P::OutputStream::Subs->new(
        'WRITE_RECORD' => sub
        {
            my $r = shift;

            push @$rs, $r;
        },
        'CLOSE' => sub
        {
            $this->_generate_table($os, $rs);
            $os->close();
        }
    );
}

sub _generate_table
{
    my $this = shift;
    my $os = shift;
    my $rs = shift;

    my $x_keys = $this->{'X_KEYS'};
    my $y_keys = $this->{'Y_KEYS'};
    my $pins = $this->{'PINS'};
    my $v_keys = $this->{'V_KEYS'};

    my $cell_tuples = [];
    RECORD: for my $r (@$rs)
    {
        # Skip immediately if it fails to match any pins.
        for my $k (keys(%$pins))
        {
            my $v = Amling::R4P::Utils::get_path($r, $k);
            next RECORD unless(defined($v) && $v eq $pins->{$k});
        }

        # Now figure out VALUE keys if we need to
        my $r_v_keys;
        if(@$v_keys)
        {
            $r_v_keys = $v_keys;
        }
        else
        {
            my $unused_keys = {map { $_ => 1 } keys(%$r)};
            delete $unused_keys->{$_} for(keys(%$pins));
            delete $unused_keys->{$_} for(@$x_keys, @$y_keys);
            $r_v_keys = [sort(keys(%$unused_keys))];
        }

        for my $v_key (@$r_v_keys)
        {
            my $xs = [];
            my $ys = [];
            for my $pair ([$x_keys, $xs], [$y_keys, $ys])
            {
                my ($keys, $values) = @$pair;
                for my $k (@$keys)
                {
                    push @$values, ($k eq 'VALUE' ? $v_key : Amling::R4P::Utils::get_path($r, $k));
                }
            }

            my $v = Amling::R4P::Utils::get_path($r, $v_key);

            push @$cell_tuples, [$xs, $ys, $v];
        }
    }

    my $x_header_tree;
    my $y_header_tree;
    for my $tuple ([\$x_header_tree, 0, $x_keys, 'X',], [\$y_header_tree, 1, $y_keys, 'Y'])
    {
        my ($pz_header_tree, $tuple_index, $z_keys, $z) = @$tuple;

        my $rows = [map { $_->[$tuple_index] } @$cell_tuples];

        my $sorters = [map { $_->{'instance'} } @{$this->{$z . '_SORTS'}}];
        if(@$sorters)
        {
            my $pairs = [];
            for my $row (@$rows)
            {
                my $r = {};
                for(my $i = 0; $i < @$z_keys; ++$i)
                {
                    Amling::R4P::Utils::set_path($r, $z_keys->[$i], $row->[$i]);
                }
                push @$pairs, [$row, $r];
            }

            my $cmp = sub
            {
                my $pair1 = shift;
                my $pair2 = shift;
                my $r1 = $pair1->[1];
                my $r2 = $pair2->[1];

                for my $sorter (@$sorters)
                {
                    my $r = $sorter->cmp($r1, $r2);
                    return $r if($r != 0);
                }

                return 0;
            };

            $rows = [map { $_->[0] } sort { $cmp->($a, $b) } @$pairs];
        }

        $$pz_header_tree = _build_header_tree($rows, scalar(@$z_keys));
    }

    my $width = scalar(@$y_keys) + 1 + $x_header_tree->[4];
    my $height = scalar(@$x_keys) + 1 + $y_header_tree->[4];

    my $cells = [map { [map { undef } (1..$height)] } (1..$width)];

    for(my $i = 0; $i < @$x_keys; ++$i)
    {
        $cells->[scalar(@$y_keys)]->[$i] = $x_keys->[$i];
    }
    for(my $i = 0; $i < @$y_keys; ++$i)
    {
        $cells->[$i]->[scalar(@$x_keys)] = $y_keys->[$i];
    }

    _visit_header_tree_cells($x_header_tree, sub { $cells->[scalar(@$y_keys) + 1 + $_[1]]->[$_[0]] = $_[2]; });
    _visit_header_tree_cells($y_header_tree, sub { $cells->[$_[0]]->[scalar(@$x_keys) + 1 + $_[1]] = $_[2]; });

    for my $cell_tuple (@$cell_tuples)
    {
        my ($xs, $ys, $v) = @$cell_tuple;
        my $x = scalar(@$y_keys) + 1 + _header_tree_width0($x_header_tree, $xs);
        my $y = scalar(@$x_keys) + 1 + _header_tree_width0($y_header_tree, $ys);
        $cells->[$x]->[$y] = $v;
    }

    my $widths = [];
    for(my $x = 0; $x < $width; ++$x)
    {
        my $max_width = 0;
        for(my $y = 0; $y < $height; ++$y)
        {
            my $v = $cells->[$x]->[$y];
            $v = Amling::R4P::Utils::pretty_string($v);
            $cells->[$x]->[$y] = $v;
            $max_width = length($v) if(length($v) > $max_width);
        }
        push @$widths, $max_width;
    }

    my $divider = sub
    {
        my @line = ('+');
        for(my $x = 0; $x < $width; ++$x)
        {
            push @line, ('-' x $widths->[$x]);
            push @line, '+';
        }
        $os->write_line(join('', @line));
    };

    $divider->();
    for(my $y = 0; $y < $height; ++$y)
    {
        my @line = ('|');
        for(my $x = 0; $x < $width; ++$x)
        {
            my $v = $cells->[$x]->[$y];
            push @line, $v;
            push @line, (' ' x ($widths->[$x] - length($v)));
            push @line, '|';
        }
        $os->write_line(join('', @line));
        $divider->();
    }
}

sub _build_header_tree
{
    my $rows = shift;
    my $row_len = shift;

    # Step 1, build order and recursive shape

    my $root = [[], {}];
    for my $row (@$rows)
    {
        my $p = $root;
        for my $v (@$row)
        {
            my $p2 = $p->[1]->{$v};
            if(!$p2)
            {
                push @{$p->[0]}, $v;
                $p2 = $p->[1]->{$v} = [[], {}];
            }
            $p = $p2;
        }
    }

    # Step 2, figure out positions
    _build_header_tree_pos($root, $row_len, -1, 0);

    return $root;
}

sub _build_header_tree_pos
{
    my $root = shift;
    my $len = shift;
    my $depth0 = shift;
    my $width0 = shift;

    my $width1;
    if($len == 0)
    {
        $width1 = $width0 + 1;
    }
    else
    {
        $width1 = $width0;
        for my $v (@{$root->[0]})
        {
            my $root2 = $root->[1]->{$v};
            $width1 = _build_header_tree_pos($root2, $len - 1, $depth0 + 1, $width1);
        }
    }

    push @$root, $depth0, $width0, $width1;
    return $width1;
}

sub _visit_header_tree_cells
{
    my $root = shift;
    my $cb = shift;

    for my $v (@{$root->[0]})
    {
        my $root2 = $root->[1]->{$v};
        $cb->($root2->[2], $root2->[3], $v);
        _visit_header_tree_cells($root2, $cb);
    }
}

sub _header_tree_width0
{
    my $root = shift;
    my $row = shift;

    my $p = $root;
    for my $v (@$row)
    {
        $p = $p->[1]->{$v};
    }

    return $p->[3];
}

sub names
{
    return ['to-ptable'];
}

1;
