ruff
==

[![Gem Version](https://badge.fury.io/rb/ruff.svg)](https://badge.fury.io/rb/ruff)

ONE-SHOT Algebraic Effects Library for Ruby!

```ruby
require "ruff"

double = Ruff.instance
triple = Ruff.instance
log = Ruff.instance

h1 = Ruff.handler
  .on(double){|k, v| k[v * 2] }
  .on(triple){|k, v| k[v * 3] }

h2 = Ruff.handler.on(log){|k, msg|
  k[]
  puts "logger: #{msg}"
}

h1.run{
  h2.run{
    v = double.perform 2
    log.perform (v + 2)
    puts triple.perform 3
  }
}
# ==> prints
# 9
# logger: 6
```

# pre-defined effect and handlers
They have `with` method to handle the effects, and `Instance` class to instanciate and handle the indivisual effect objects.

```ruby
require "ruff"
require "ruff/standard"

include Ruff::Standard

Defer.with {
  state1 = State::Instance.new
  state2 = State::Instance.new

  state1.with_init(10) {
    CurrentTime.with {
      puts CurrentTime.get
    }

    state2.with_init("") {
      3.times{
        state1.modify {|s| s + 1 }
        state2.put "#{state1.get}!"

        s1 = state1.get
        s2 = state2.get

        Defer.register {
          puts s1, s2
        }
      }
    }
  }
}

# ==>
# 2019-10-03 03:24:34 +0900
# 13
# 13!
# 12
# 12!
# 11
# 11!
```

## `Ruff::Standard::State`
### `with_init`
<!-- This method handles state-like effects like `with` , but it requires initial state. -->
<!-- `with { task }` is short hand for `with_init(0) { task }` . -->

### `get`
### `put`
### `modify`

## `Ruff::Standard::Defer`
### `register`

## `Ruff::Standard::CurrentTime`
### `get`

# LICENSE
MIT
