# TRUTH SERUM

Features

* Parses `keywords` as well as `filters:value` syntax.
* Handles `"quotes spaces ::: escapes \r\n newlines"`.
* Has proper lexing and parsing system instead of a regular expression.

# INSTALL

```
gem install truth_serum
```

# USAGE

```rb
require 'truth_serum'

result = TruthSerum.parse("hello world key:value -negate:yes")
puts result.terms
puts result.filters
puts result.negative_filters
```

# LICENSE

MIT
