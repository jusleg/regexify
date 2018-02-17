# Where the regex magic happens
class Regexify

  # Class to raise errors
  class Error < StandardError; end

  # a small list of popular regex tokens that are available with regexify
  PATTERNS = {
    number: '0-9',
    uppercase: 'A-Z',
    lowercase: 'a-z',
    letter: 'a-zA-Z',
    alphanumeric: 'a-zA-Z0-9',
    anything: '.',
    whitespace: '\\s',
    tab: '\\t',
    space: ' '
  }

  # chars that needs to be escaped in a regex
  ESCAPED_CHARS = %w(* . ? ^ + $ | ( ) [ ] { } \\)

  # default constructor
  def initialize
    @str = ""
    @complete = false
  end

  # Defines the beginning of the regex and adds `^`
  # @param args symbols and strings (supporting single and multiple characters)
  # @param exactly specific number of repetition
  # @param range range of repetition
  # @return [Regexify] current regex object
  def begin_with(*args, exactly: nil, range: nil)
    raise Regexify::Error.new('#begin_with? called multiple times') unless @str.empty?
    @str += "^#{parse(args, exactly: exactly, range: range)}"
    self
  end

  # Defines the ending of the regex and adds `$`
  # @param args symbols and strings (supporting single and multiple characters)
  # @param exactly specific number of repetition
  # @param range range of repetition
  # @return [Regexify]
  def end_with(*args, exactly: nil, range: nil)
    raise Regexify::Error.new('#end_with? called multiple times') if @complete
    @str += "#{parse(args, exactly: exactly, range: range)}$"
    @complete = true
    self
  end

  # Adds a new part to the regex
  # @param args symbols and strings (supporting single and multiple characters)
  # @param exactly specific number of repetition
  # @param range range of repetition
  # @return [Regexify]
  def then(*args, exactly: nil, range: nil)
    @str += parse(args, exactly: exactly, range: range)
    self
  end

  # Adds a new part to the regex that is negated using `^`
  # @param args symbols and strings (supporting single and multiple characters)
  # @param exactly specific number of repetition
  # @param range range of repetition
  # @return [Regexify] current regex object
  def not(*args, exactly: nil, range: nil)
    @str += parse(args, exactly: exactly, range: range).insert(1, "^")
    self
  end

  # Converts Regexify object to Regexp
  def regex
    Regexp.new(@str)
  end

  private

  def parse(args, exactly: nil, range: nil)
    return_val = ""
    if args.length == 1
      return_val = singular_pattern(args.first, extract_regex(args.first))
    elsif contains_symbols?(args)
      return_val = "["
      args.each do |arg|
        return_val += extract_regex(arg)
      end
      return_val += "]"
    else
      return_val = "("
      args.each do |arg|
        return_val += extract_regex(arg) + "|"
      end
      return_val[-1] = ")"
    end
    return_val + quantity(exactly, range)
  end

  def extract_regex(arg)
    regex_str = ""
    if arg.is_a? Symbol
      raise Regexify::Error.new('symbol not defined in patterns') unless PATTERNS.key?(arg)
      PATTERNS[arg]
    else
      escape(arg)
    end
  end

  def singular_pattern(arg, pattern)
    if arg.is_a? Symbol
      "[#{pattern}]"
    elsif pattern.length > 1
      "(#{pattern})"
    else
      pattern
    end
  end

  def quantity(exact, range)
    if range && range.length == 2
      "{#{range[0]},#{range[1]}}"
    elsif range
      "{#{range[0]},}"
    elsif exact.to_i > 1
      "{#{exact}}"
    else
      ""
    end
  end

  def escape(pattern)
    escaped_pattern = ""
    pattern.to_s.chars.each do |char|
      escaped_pattern += ESCAPED_CHARS.include?(char) ? "\\#{char}" : char
    end
    escaped_pattern
  end

  def contains_symbols?(args)
    args.each do |arg|
      return true if arg.is_a? Symbol
    end
    return false
  end
end
