# Regexify [![Gem Version](https://badge.fury.io/rb/regexify.svg)](https://badge.fury.io/rb/regexify) [![codebeat badge](https://codebeat.co/badges/91f5a907-8005-41f5-9e34-72370767ea36)](https://codebeat.co/projects/github-com-jusleg-regexify-master)

[View docs](http://www.rubydoc.info/gems/regexify/0.0.1/Regexify)

Having fun with regex. Is it possible? I think so.


### Installation

```
gem install regexify
```


### Usage

Regexify provides a simple interface to write regex in ruby

Four methods can be used to create the regex:

* `begin_with`
* `then`
* `not`
* `end_with`

And the `regex` method will convert it to a `Regexp` object.

You can use strings/characters using these methods as well as symbols from the list below:

* **number:** `0-9`
* **uppercase:** `A-Z`
* **lowercase:** `a-z`
* **letter:** `a-zA-Z`
* **alphanumeric:** `a-zA-Z0-9`
* **anything:** `.`
* **whitespace:** `\s`
* **tab:** `\t`
* **space:** ` `

`Range` and `exactly` can be used to specify a number of occurrences.

Here is a basic example:

```ruby
Regexify.new
  .begin_with('hello', 'hola', range: [2,3])
  .then(',')
  .then('world', exactly: 2)
  .end_with('!', range: [1,]).regex

 => /^(hello|hola){2,3},(world){2}!{1,}$/ 
 
Regexify.new
  .begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .end_with('!').regex

 => /^[A-Z]{3}[0-9-]{2,10}[^a-zA-Z0-9]!$/
```

This project was heavily inspired by [regularity](https://github.com/andrewberls/regularity)

### LICENSE

This gem is MIT licensed, please see LICENSE for more information.
