ruff
==

ONE-SHOT Algebraic Effects Library for Ruby!

```ruby
require 'ruff'

double = Ruff.instance
log = Ruff.instance

h1 = Ruff.handler.on(double, ->(k, v){
  k[v * 2]
})

h2 = Ruff.handler.on(log, ->(k, msg){
  k[]
  puts "logger: #{msg}"
})

h1.run{
  h2.run{
    v = double.perform 2
    log.perform (v + 2)
    puts "ok"
  }
}
# ==> prints
# ok
# logger: 6
```
