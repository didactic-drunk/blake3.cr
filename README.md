# BLAKE3
[![Build Status](https://travis-ci.org/didactic-drunk/blake3.cr.svg?branch=master)](https://travis-ci.org/didactic-drunk/blake3.cr)
[![GitHub release](https://img.shields.io/github/release/didactic-drunk/blake3.cr.svg)](https://github.com/didactic-drunk/blake3.cr/releases)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://didactic-drunk.github.io/blake3.cr/)

Blake3 using the official [BLAKE3 c](https://github.com/BLAKE3-team/BLAKE3/tree/master/c) implementation.

## Features
- [x] Fast.  ~2x faster than [Sodium::Digest::Blake2b](https://github.com/didactic-drunk/sodium.cr#blake2b).
- [x] Uses Crystal's Digest API.
- [x] Keyed digests.
- [ ] Key derivation.
- [x] Configurable final size.
- [ ] Streaming final output.
- [x] Tested against official test vectors.
- [x] Builds a blake3 c static library.

## Speed

[examples/blake3_hash.cr](https://github.com/didactic-drunk/blake3.cr/blob/master/examples/blake3_hash.cr) 
is approximately the same speed as [b3sum](https://github.com/BLAKE3-team/BLAKE3#the-b3sum-utility) with 1 thread or mmap disabled.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     blake3:
       github: didactic-drunk/blake3.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "blake3"
```

```crystal
digest = Digest::Blake3.new
digest.update data
p digest.final.hexstring
```

```crystal
output_size = 1024
digest = Digest::Blake3.new(output_size)
digest.update data
p digest.final.hexstring => ...a.very.long.string...
```
   
```crystal
digest = Digest::Blake3.new(key: "super secret exactly 32 byte key")
digest.update data
p digest.final.hexstring
```

For further API documentation see [Crystal's Digest API](https://crystal-lang.org/api/0.36.1/Digest.html)

## Contributing

1. Fork it (<https://github.com/didactic-drunk/blake3/fork>)
2. **Install a formatting check git hook (ln -sf ../../scripts/git/pre-commit .git/hooks)**
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Contributors

- [Didactic Drunk](https://github.com/didactic-drunk) - creator and maintainer
