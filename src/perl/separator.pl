use Marpa::R2;
use Data::Dumper;

my $source = <<'END_OF_SOURCE';
:start ::= S
S ::= a b S
S ::= a

a ~ 'a'
b ~ 'b'
END_OF_SOURCE

my $grammar = Marpa::R2::Scanless::G->new( {default_action => '::array', source => \$source});
my $recce = Marpa::R2::Scanless::R->new( {grammar => $grammar});
my $input = 'ab';
$recce->read(\$input);

my $value = ${$recce->value};
print "Output:\n".Dumper($value);



my $source = <<'END_OF_SOURCE';
:start ::= S
S ::= a+ proper => 1 separator => b

a ~ 'a'
b ~ 'b'
END_OF_SOURCE

my $grammar = Marpa::R2::Scanless::G->new( {default_action => '::array', source => \$source});
my $recce = Marpa::R2::Scanless::R->new( {grammar => $grammar});
my $input = 'ab';
$recce->read(\$input);

my $value = ${$recce->value};
print "Output:\n".Dumper($value);
