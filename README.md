# marpa
[![GitHub release](https://img.shields.io/github/release/omarroth/marpa.svg)](https://github.com/omarroth/marpa/releases)

Marpa is a parsing algorithm.  
From the [official Marpa website](http://jeffreykegler.github.io/Marpa-web-site/):

> Marpa is fast. It parses in **linear time**:
>
> - **all** the grammar classes that recursive descent parses;
> - the grammar class that the yacc family parses;
> - in fact, **any** unambiguous grammars, with a couple of exceptions that are not likely to be an issue in practice (see [quibbles](http://jeffreykegler.github.io/Marpa-web-site/#quibbles)); and
> - **all** ambiguous grammars that are unions of a finite set of any of the above grammars.

(emphasis added)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  marpa:
    github: omarroth/marpa
```

## Usage

```crystal
require "marpa"

parser = Marpa::Parser.new

grammar = <<-'END_BNF'
# Grammar from https://metacpan.org/pod/distribution/Marpa-R2/pod/Semantics.pod
:start ::= Expression
Expression ::= Number
  | '(' Expression ')'
 || Expression '**' Expression
 || Expression '*' Expression
  | Expression '/' Expression
 || Expression '+' Expression
  | Expression '-' Expression

Number ~ [\d]+

:discard ~ whitespace
whitespace ~ [\s]+
END_BNF

input = "3 + 5 * 10"

pp parser.parse(input, grammar) # => [["3"], "+", [["5"], "*", ["10"]]]
```

See `examples/` for a more thorough demonstration of this interface's capabilities, including a JSON parser.

## Features

- Support for PCREs in lexing (see `examples/json/` for example).
- Speed guarantees of the original Marpa algorithm (see [above](#marpa)).
- Supports ambiguous and null rules.

## Limitations

- Does not currently allow user to access all parses of ambiguous input.
- Several other important features of the [SLIF interface](https://metacpan.org/pod/distribution/Marpa-R2/pod/Scanless/DSL.pod), on which this one is based.

## Contributing

1.  Fork it ( https://github.com/omarroth/marpa/fork )
2.  Create your feature branch (git checkout -b my-new-feature)
3.  Commit your changes (git commit -am 'Add some feature')
4.  Push to the branch (git push origin my-new-feature)
5.  Create a new Pull Request

## Contributors

- [omarroth](https://github.com/omarroth) Omar Roth - creator, maintainer
