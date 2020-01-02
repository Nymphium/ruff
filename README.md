ruff
==

[![Gem Version](https://badge.fury.io/rb/ruff.svg)](https://badge.fury.io/rb/ruff)

ONE-SHOT Algebraic Effects Library for Ruby!

```ruby
require "ruff"

Double = Ruff.instance
Triple = Ruff.instance
Log = Ruff.instance

h1 = Ruff.handler
  .on(Double){|k, v| k[v * 2] }
  .on(Triple){|k, v| k[v * 3] }

h2 = Ruff.handler.on(Log){|k, msg|
  k[]
  puts "logger: #{msg}"
}

h1.run{
  h2.run{
    v = Double.perform 2
    Log.perform (v + 2)
    puts Triple.perform 3
  }
}
# ==> prints
# 9
# logger: 6
```

# Feature
## ***One-shot*** algebraic effects
You can access the delimited continuation which can run only once.
Even the limitation exists, you can write powerful control flow manipulation, like async/await, call1cc.

We have an formal definition for the implementation, by showing a conversion from algebraic effects and handlers to asymmetric coroutines.
See [here](https://nymphium.github.io/2018/12/09/asymmetric-coroutines%E3%81%AB%E3%82%88%E3%82%8Boneshot-algebraic-effects%E3%81%AE%E5%AE%9F%E8%A3%85.html) (in Japanese).

# Pre-defined effect and handlers
We provide some ready-to-use effect and handlers.
You can use quickly powerful control flows.

- [`Ruff::Standard::State`](https://nymphium.github.io/ruff/Ruff/Standard/State.html)
- [`Ruff::Standard::Defer`](https://nymphium.github.io/ruff/Ruff/Standard/Defer.html)
- [`Ruff::Standard::CurrentTime`](https://nymphium.github.io/ruff/Ruff/Standard/CurrentTime.html)
- [`Ruff::Standard::MeasureTime`](https://nymphium.github.io/ruff/Ruff/Standard/MeasureTime.html)
- [`Ruff::Standard::Async`](https://nymphium.github.io/ruff/Ruff/Standard/Async.html)
- [`Ruff::Standard::Call1cc`](https://nymphium.github.io/ruff/Ruff/Standard/Call1cc.html)

# LICENSE
MIT
