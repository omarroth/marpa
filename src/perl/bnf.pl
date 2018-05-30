# Copyright (c) 2013 Peter Stuifzand
use strict;
use Marpa::R2;
use Data::Dumper;
use JSON;

open(my $fh, "<", "src/bnf/metag.bnf")
  or die "";
my $input = do {local $/; <$fh>};

my $g = Marpa::R2::Scanless::G->new(
	{
		default_action => '::array',
		source         => \$input,
	}
);

my $re = Marpa::R2::Scanless::R->new({ grammar => $g });

$re->read(\$input);
my $value = ${$re->value};
my $json = JSON->new;

print $json->pretty->encode($value);
