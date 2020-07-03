# BLAKE3
[![Build Status](https://travis-ci.org/didactic-drunk/blake3.cr.svg?branch=master)](https://travis-ci.org/didactic-drunk/blake3.cr)
[![GitHub release](https://img.shields.io/github/release/didactic-drunk/blake3.cr.svg)](https://github.com/didactic-drunk/blake3.cr/releases)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://didactic-drunk.github.io/blake3.cr/)

Blake3 using the official [BLAKE3 c](https://github.com/BLAKE3-team/BLAKE3/tree/master/c) implementation.

WARNING: This is new software.  Not much testing has been done but the API uses crystal's Digest API and is unlikely to change.
If you're reading this past 2020-10 it's probably stable and this warning is old.

## Features
- [x] Fast.  ~2x faster than Sodium::Digest::Blake2b.
- [x] Uses Crystal's Digest API.
- [x] Keyed digests.
- [ ] Key derivation.
- [x] Configurable final size.
- [ ] Streaming final output.
- [x] Builds a blake3 c static library.

## Todo
- [ ] Use official specs.

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
require "digest/blake3"
```

```crystal
digest = Digest::Blake3.new
digest.update data
p digest.final.hexstring
```

## Contributing

1. Fork it (<https://github.com/your-github-user/blake3/fork>)
2. **Install a formatting check git hook (ln -sf ../../scripts/git/pre-commit .git/hooks)**
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Contributors

- [Didactic Drunk](https://github.com/didactic-drunk) - creator and maintainer
