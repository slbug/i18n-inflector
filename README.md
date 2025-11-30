# i18n-inflector

**i18n-inflector-3 version `3.0.0`** (Ruby 3.4+ compatible fork)

* https://github.com/slbug/i18n-inflector
* mailto:sl.bug.sl@gmail.com

## Summary

This library contains a backend module for I18n that adds extra functionality to the standard backend. It overwrites the translate method to interpolate additional inflection tokens present in translations.

This is a modernized fork of the original i18n-inflector gem, updated to work with Ruby 3.4+ and Ruby 4.0.0-preview2.

## Synopsis

```ruby
require 'i18n-inflector'

I18n.translate('to_be', number: :singular,
                        tense: :past,
                        person: 2)
#=> You were here

I18n.translate('welcome', gender: :female)
#=> Dear Lady
```

## Why?

You can use I18n Inflector to create translations for highly inflected languages (like those belonging to Slavic language family). You can also use it in translation services that may operate on sentences instead of exact words.

## When?

It is intended to be used in web projects or other projects where translations are performed by many people, yet there is a need to inflect sentences with external variables. To achieve similar functionality lambdas can be used, but including many Proc objects might be considered unsafe or memory consuming.

See [i18n-inflector-rails](https://rubygems.org/gems/i18n-inflector-rails) if you need Rails integration.

## How?

I18n Inflector lets you build your own inflection patterns contained in translation entries. The patterns may contain simple conditions and tokens, which combined with parameters passed to `I18n.translate` method can produce inflected strings.

* See [USAGE](docs/USAGE) for detailed information about the usage.
* See [EXAMPLES](docs/EXAMPLES) for examples.
* See [whole documentation](http://rubydoc.info/gems/i18n-inflector-3/) to browse all documents.

## Features

* Inline inflection using patterns in translation data
* Key-based inflection using individual inflection keys
* Definable inflection kinds and tokens
* Easy to use public API for inflection data
* Configurable using special scope of translation data
* Lazily evaluated Proc and Method objects as inflection options
* Complex patterns support; inflection by more than one kind at a time
* Negative matching, aliases, default tokens, token groups and more…

## Description

The I18n Inflector extends the translate method from I18n to interpolate additional inflection tokens present in translations. These tokens may appear in **patterns** which are contained within `@{` and `}` symbols. Configuration is stored in translation data, in a scope `<locale>.i18n.inflections`, where `locale` is a locale subtree.

You can create your own inflection kinds (gender, title, person, time, author, etc.) to group tokens in meaningful, semantical sets. That means you can apply Inflector to do simple inflection by gender or person when a language requires it.

It adds the `inflector` object to the default backend so you can use many methods for accessing loaded inflection data at runtime, or to set up global switches that control the engine.

## Short example

Example configuration using translation data:

```yaml
en:
  i18n:
    inflections:
      gender:
        f: "female"
        m: "male"
        n: "neuter"
        female: :@f
        male: :@m
        default: :n
```

Example translation data:

```yaml
en:
  welcome: "Dear @{f:Lady|m:Sir|n:You|All}!"
  
  '@same_but_as_key':
    f: "Lady"
    m: "Sir"
    n: "You"
    '@prefix': "Dear "
    '@suffix': "!"
    '@free': "All"
```

### Note about YAML parsing

The examples use symbol notation (`:@f`) for special values to ensure compatibility with modern YAML parsers including Psych.

## New features

From version 2.1.0 the Inflector supports **named patterns**, which can be used when there is a need to be strict and/or to use the same token names but assigned to different kinds. Example:

```yaml
welcome: "Dear @gender{f:Lady|m:Sir|n:You|All}"
```

From version 2.2.0 the Inflector supports **complex patterns**, which can be used to inflect a sentence or word by more than one kind. This is very helpful for highly inflected languages. Example:

```yaml
welcome: "Dear @gender+number{f+s:Lady|f+p:Ladies|m+s:Sir|m+p:Gentlemen|All}"
```

## Modernization (v3.0.0)

This fork has been modernized for Ruby 3.4+ and Ruby 4.0.0-preview2:

### Breaking Changes

* **Minimum Ruby version**: 3.4+ (was 1.9+)
* **Gem name**: Changed to `i18n-inflector-3` to avoid conflicts
* **Build system**: Migrated from Hoe to standard Bundler/Gemspec
* **Test framework**: Migrated from Test::Unit to Minitest

### Technical Improvements

* **Frozen string literals**: All files use `frozen_string_literal: true`
* **HSet implementation**: Updated to use public `Set#include?` API instead of internal `@hash`
* **Dependencies**: Updated to modern versions
* **Code style**: Modernized Ruby idioms and syntax

### Migration from v2.6.7

No API changes - this is a drop-in replacement. Just update your Gemfile:

```ruby
# Old
gem 'i18n-inflector', '~> 2.6'

# New
gem 'i18n-inflector-3', '~> 3.0'
```

The require statement remains the same:

```ruby
require 'i18n-inflector'  # Still works!
```

## Requirements

* [i18n](https://rubygems.org/gems/i18n) >= 0.6.0
* [rake](https://rubygems.org/gems/rake) >= 13.0
* Ruby >= 3.4

## Download

### Source code

* https://github.com/slbug/i18n-inflector
* `git clone git://github.com/slbug/i18n-inflector.git`

### Gem

* https://rubygems.org/gems/i18n-inflector-3

## Installation

```bash
gem install i18n-inflector-3
```

Or add to your Gemfile:

```ruby
gem 'i18n-inflector-3', '~> 3.0', require: 'i18n-inflector'
```

## Detailed example

**YAML:**

```yaml
en:
  i18n:
    inflections:
      gender:
        f: "female"
        m: "male"
        n: "neuter"
        o: "other"
        default: :n
 
  welcome: "Dear @{f:Lady|m:Sir|n:You|All}"
```

**Code:**

```ruby
I18n.t('welcome')
# => "Dear You"

I18n.t('welcome', gender: :m)
# => "Dear Sir"

I18n.t('welcome', gender: :unknown)
# => "Dear You"

I18n.inflector.options.unknown_defaults = false
I18n.t('welcome', gender: :unknown)
# => "Dear All"

I18n.t('welcome', gender: :o)
# => "Dear All"

I18n.inflector.options.excluded_defaults = true
I18n.t('welcome', gender: :o)
# => "Dear You"
```

## More information

* See `I18n::Inflector::API` class documentation for detailed information about the API
* See `I18n::Backend::Inflector` module documentation for detailed information about the internals

## Tests

You can run tests with:

```bash
bundle exec rake test
# or
./bin/test
```

## Common rake tasks

* `bundle exec rake test` – performs tests
* `bundle exec rake gem` – builds package (output in the subdirectory `pkg`)
* `bundle exec rake docs` – render the documentation (output in the subdirectory `doc`)

## Credits

Original gem by Paweł Wilk (pw@gnu.org).

[Heise Media Polska](http://www.heise-online.pl/) supports Free Software and contributed to the original library.

Modernization for Ruby 3.4+ by Alexander Grebennik.

## License

Copyright (c) 2011-2013 by Paweł Wilk.
Copyright (c) 2025 by Alexander Grebennik (modernization).

i18n-inflector is copyrighted software owned by Paweł Wilk (pw@gnu.org).
You may redistribute and/or modify this software as long as you comply with either the terms of the LGPL (see [LGPL](docs/LGPL)), or Ruby's license (see [COPYING](docs/COPYING)).

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
