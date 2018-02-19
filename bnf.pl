# Copyright (c) 2013 Peter Stuifzand
use strict;
use Marpa::R2;
use Data::Dumper;

my $g = Marpa::R2::Scanless::G->new(
	{
		default_action => '::array',
		source         => \(<<'END_OF_SOURCE'),

END_OF_SOURCE
	}
);

my $re = Marpa::R2::Scanless::R->new({ grammar => $g });
my $input = <<'INPUT';

INPUT

print "Trying to parse:\n$input\n\n";
$re->read(\$input);
my $value = ${$re->value};
print "Output:\n".Dumper($value);

