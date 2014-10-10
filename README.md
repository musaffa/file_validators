# File Validators

[![Gem Version](http://img.shields.io/gem/v/file_validators.svg)](https://rubygems.org/gems/file_validators)
[![Build Status](https://travis-ci.org/musaffa/file_validators.svg)](https://travis-ci.org/musaffa/file_validators)
[![Dependency Status](http://img.shields.io/gemnasium/musaffa/file_validators.svg)](https://gemnasium.com/musaffa/file_validators)
[![Coverage Status](http://img.shields.io/coveralls/musaffa/file_validators.svg)](https://coveralls.io/r/musaffa/file_validators)
[![Code Climate](http://img.shields.io/codeclimate/github/musaffa/file_validators.svg)](https://codeclimate.com/github/musaffa/file_validators)

File Validators gem adds to file size and content type validations to ActiveModel. Any module that uses ActiveModel, for example ActiveRecord, can use these file validators.

## Support

* ActiveModel versions: 3 and 4.
* Rails versions: 3 and 4.

## Installation

Add the following to your Gemfile:

```ruby
gem 'file_validators'
```

## Examples

ActiveModel example:

```ruby
class Profile
  include ActiveModel::Validations

  attr_accessor :avatar
  validates :avatar, file_size: { less_than_or_equal_to: 100.kilobytes },
                     file_content_type: { in: ['image/jpeg', 'image/png', 'image/gif'] } 
end
```
ActiveRecord example:

```ruby
class Profile < ActiveRecord::Base
  validates :avatar, file_size: { less_than_or_equal_to: 100.kilobytes },
                     file_content_type: { in: ['image/jpeg', 'image/png', 'image/gif'] }
end
```

## API

### File Size Validator:

* `in`: A range of bytes
```ruby
validates :avatar, file_size: { in: 100.kilobytes..1.megabyte }
```
* `less_than_or_equal_to`: Less than or equal to a number in bytes
```ruby
validates :avatar, file_size: { less_than_or_equal_to: 50.bytes } 
```
* `greater_than_or_equal_to`: Greater than or equal to a number in bytes
```ruby
validates :avatar, file_size: { greater_than_or_equal_to: 50.bytes } 
```
Following two examples are equivalent:
```ruby
validates :avatar, file_size: { greater_than_or_equal_to: 500.kilobytes,
                                less_than_or_equal_to: 3.megabytes }
```
```ruby
validates :avatar, file_size: { in: 500.kilobytes..3.megabytes }
```
* `less_than`: Less than a number in bytes
```ruby
validates :avatar, file_size: { less_than: 2.gigabytes }
```
* `greater_than`: greater than a number in bytes
```ruby
validates :avatar, file_size: { greater_than: 1.byte } 
```
* `message`: Error message to display. With all the options above except `:in`, you will get `count` as a replacement. 
With `:in` you will get `min` and `max` as replacements. 
`count`, `min` and `max` each will have its value and unit together.
You can write error messages without using any replacement.
```ruby
validates :avatar, file_size: { less_than: 100.kilobytes,
                                message: 'avatar file size should be less than %{count}' } 
```
```ruby
validates :document, file_size: { in: 1.kilobyte..1.megabyte,
                                  message: 'document should be within %{min} and %{max}' }
```
* `if`: A lambda or name of an instance method. Validation will only be run if this lambda or method returns true.
* `unless`: Same as `if` but validates if lambda or method returns false.

### File Content Type Validator

* `in`: Allowed content types.  Can be a single content type or an array.  Each type can be a String or a Regexp. Allows all by default.
```ruby
# string
validates :avatar, file_content_type: { in: 'image/jpeg' }
```
```ruby
# array of strings
validates :attachment, file_content_type: { in: ['image/jpeg', 'image/png', 'text/plain'] }
```
```ruby
# regexp
validates :avatar, file_content_type: { in: /^image\/.*/ }
```
* `exclude`: Forbidden content types. Can be a single content type or an array.  Each type can be a String or a Regexp.
```ruby
# string
validates :avatar, file_content_type: { in: /^image\/.*/, exclude: 'image/jpeg' }
```
```ruby
# array of strings
validates :attachment, file_content_type: { exclude: ['image/jpeg', 'text/plain'] }
```
```ruby
# regexp
validates :avatar, file_content_type: { exclude: /^image\/.*/ }
```
* `message`: The message to display when the uploaded file has an invalid content type.
You will get `types` as a replacement. You can write error messages without using any replacement.
```ruby
validates :avatar, file_content_type: { in: ['image/jpeg', 'image/gif'],
                                        message: 'should have content type %{types}' }
```
```ruby
validates :avatar, file_content_type: { in: ['image/jpeg', 'text/plain'],
                                        message: 'Avatar only allows jpeg and gif image files' }
```
* `if`: A lambda or name of an instance method. Validation will only be run is this lambda or method returns true.
* `unless`: Same as `if` but validates if lambda or method returns false.

## i18n Translations

By default, Size Validator will use the error messages of `:less_than`, `:greater_than_or_equal_to` etc from `errors.messages` of your locale. `errors.messages` translation is available under ActiveModel's locale.

For `:in` and `:exclude` you have to write your own error messages under `errors.messages`.  

You can override all of them with the `:message` option.

For unit format, it will use `number.human.storage_units.format` from your locale.
For unit translation, it will use `number.human.storage_units`.
Rails applications already have these translations either in ActiveSupport's locale (Rails 4) or in ActionView's locale (Rails 3).
In case your setup doesn't have the translations, here's an example for `en`:

```yml
en:
  number:
    human:
      storage_units:
        format: "%n %u"
        units:
          byte:
            one:   "Byte"
            other: "Bytes"
          kb: "KB"
          mb: "MB"
          gb: "GB"
          tb: "TB"
```

## Tests

```ruby
rake
rake test:unit
rake test:integration
```

## Problems

Please use GitHub's [issue tracker](http://github.com/musaffa/file_validations/issues).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Inspirations

* [PaperClip](https://github.com/thoughtbot/paperclip)

## License

This project rocks and uses MIT-LICENSE.
