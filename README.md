# Matter Compiler [![Build Status](https://travis-ci.org/apiaryio/matter_compiler.png?branch=master)](https://travis-ci.org/apiaryio/matter_compiler)
Matter Compiler is a [API Blueprint AST Media Types](https://github.com/apiaryio/snowcrash/wiki/API-Blueprint-AST-Media-Types) to [API Blueprint](https://apiblueprint.org) conversion tool. It composes an API blueprint from its serialzed AST media-type.

## Installation
Add this line to your application's Gemfile:

    gem 'matter_compiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install matter_compiler

## Usage
To compose a blueprint from a serialized AST media-type run:

```sh
$ matter_compiler path/to/ast.yaml
```

See the [compose feature](features/compose.feature) for details or run `matter_compiler --help`.

## Contributing
1. Fork it (https://github.com/apiaryio/matter_compiler/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
MIT License. See the [LICENSE](LICENSE) file.
