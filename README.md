ruff
==

ONE-SHOT Algebraic Effects Library for Ruby!

```ruby
require "ruff"

eff = init

h = Handler.new
    .on(eff, ->(k, v) {
      k[v * 4]
    })

puts h.run {
  v = eff.perform 10
  v + 2
}
# ==> 42
```
