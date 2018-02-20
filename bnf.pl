# Copyright (c) 2013 Peter Stuifzand
use strict;
use Marpa::R2;
use Data::Dumper;

my $input = <<'INPUT';
:start ::= statements
statements ::= statement+
statement ::= <start rule>
  | <priority rule> | <quantified rule>
  | <discard rule>

<start rule> ::= (':start' <op declare bnf>) symbol
<priority rule> ::= lhs <op declare> alternatives
<quantified rule> ::= lhs <op declare> <single symbol> quantifier <adverb list>
<discard rule> ::= (':discard' <op declare match>) <single symbol>

<op declare> ::= <op declare bnf> | <op declare match>
alternatives ::= alternative+
    separator => <op equal priority> proper => 1
alternative ::= rhs <adverb list>

<adverb list> ::= <adverb list items>
<adverb list items> ::= <adverb item>*
<adverb item> ::= <separator specification> 
  | <proper specification>

<separator specification> ::= ('separator' '=>') <single symbol>
<proper specification> ::= ('proper' '=>') boolean

lhs ::= <symbol name>
rhs ::= <rhs primary>+
<rhs primary> ::= <single symbol> 
  | <single quoted string> 
  | <parenthesized rhs primary list>
<parenthesized rhs primary list> ::= ('(') <rhs primary list> (')')
<rhs primary list> ::= <rhs primary>+
<single symbol> ::= symbol
  | <character class>
symbol ::= <symbol name>
<symbol name> ::= <bare name>
  | <bracketed name>

:discard ~ whitespace
whitespace ~ [\s]+

<op declare bnf> ~ '::='
<op declare match> ~ '~'
<op equal priority> ~ '|'
quantifier ::= '*' | '+'

boolean ~ [01]

<bare name> ~ [\w]+
<bracketed name> ~ '<' <bracketed name string> '>'
<bracketed name string> ~ [\s\w]+

<single quoted string> ~ ['] <string without single quote or vertical space> [']
<string without single quote or vertical space> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]+

<character class> ~ '[' <cc elements> ']' 
<cc elements> ~ <cc element>+
<cc element> ~ <safe cc character>
<safe cc character> ~ [^\x{5d}\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
INPUT

my $g = Marpa::R2::Scanless::G->new(
	{
		default_action => '::array',
		source         => \$input,
	}
);

my $re = Marpa::R2::Scanless::R->new({ grammar => $g });

$re->read(\$input);
my $value = ${$re->value};
print Dumper($value);
