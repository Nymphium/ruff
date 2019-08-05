ruff
==

ONE-SHOT Algebraic Effects Library for Ruby!

```ruby
require "ruff"

double = init
log = init

h = handler
    .on(double, ->(k, v) {
      k[v * 2]
    })
    .on(log, ->(k, v) {
      puts "logger: #{v}"
      k[]
    })

h.run {
  v = double.perform 10
  log.perform v + 2
}
# ==> prints "logger: 42"
```
