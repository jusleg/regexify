#!/usr/bin/env ruby

load '../lib/regexify.rb'

# monkey patch Regexify to add 'to_s' method

class Regexify
	public
  		def to_s
    		@str
    	end
end

class RegexifyWithOptions < Regexify

	@options = nil
	
	public
	
		def options
			@options
		end
		
		def options=(opt)
			raise Regexify::Error.new("Illegal regex modifier string") \
  							unless opt.kind_of?(NilClass) || \
  								   (opt.kind_of?(String) && opt.match?(/[ixm]/))
  			@options = opt
  		end
		
		def initialize(opt = nil)
			super()
  			self.options = opt
		end
		
		# Converts Regexify object to Regexp
  		def regex
  			opts = 0
  			unless @options.nil?
  				@options = squeeze(@options)
  				opts |= Regexp::IGNORECASE if @options.match?(/i/)
				opts |= Regexp::EXTENDED if @options.match?(/x/)
				opts |= Regexp::MULTILINE if @options.match?(/m/)
  			end
  			Regexp.new(@str, opts)
  		end

	protected
	
		def squeeze(str)
			uniqs = ''
    			str.sub(/\s+/,'').each_char { |s| uniqs += s if !uniqs.include?(s) }
    			return uniqs.downcase
		end
end

class RegexifyWithAnchor < Regexify

	public
	
		def initialize
			super
		end

# Insert an anchor:
#
# \A - Matches beginning of string.
# \Z - Matches end of string. If string ends with a newline, it matches just
#        before newline
# \z - Matches end of string
# \G - Matches point where last match finished
# \b - Matches word boundaries when outside brackets; backspace (0x08) when
#        inside brackets
# \B - Matches non-word boundaries
		
		def anchor(a)
			raise Regexify::Error.new("Illegal anchor.") \
								unless a.length == 1 && a.match?(/[AZzGbB]/)	
			@str += "\\#{a}"
			self
		end 
				
# (?=pat) - Positive lookahead assertion: ensures that the following characters
#        match pat, but doesn't include those characters in the matched text

		def pos_look_ahead(pat)
			@str += "\(\?=#{pat}\)"
			self
		end
		
# (?!pat) - Negative lookahead assertion: ensures that the following characters
#        do not match pat, but doesn't include those characters in the
#        matched text

		def neg_look_ahead(pat)
			@str += "\(\?!#{pat}\)"
			self
		end

# (?<=pat) - Positive lookbehind assertion: ensures that the preceding 
#        characters match pat, but doesn't include those characters in the
#        matched text

		def pos_look_behind(pat)
			@str += "\(\?<=#{pat}\)"
			self
		end

# (?<!pat) - Negative lookbehind assertion: ensures that the preceding
#        characters do not match pat, but doesn't include those characters in 
#        the matched text

		def neg_look_behind(pat)
			@str += "\(\?<!#{pat}\)"
			self
		end
end

class RegexifyANSI < Regexify

	public
	
		def initialize
			super
			
# /[[:alnum:]]/ - Alphabetic and numeric character
# /[[:alpha:]]/ - Alphabetic character
# /[[:blank:]]/ - Space or tab
# /[[:cntrl:]]/ - Control character
# /[[:digit:]]/ - Digit
# /[[:graph:]]/ - Non-blank character (excludes spaces, control characters, 
#                   and similar)
# /[[:lower:]]/ - Lowercase alphabetical character
# /[[:print:]]/ - Like [:graph:], but includes the space character
# /[[:punct:]]/ - Punctuation character
# /[[:space:]]/ - Whitespace character ([:blank:], newline, CR, etc.)
# /[[:upper:]]/ - Uppercase alphabetical
# /[[:xdigit:]]/ - Digit allowed in a hexadecimal number (i.e., 0-9a-fA-F)

# redefinitions
#
			@patterns[:number] = '[[:digit:]]'
			@patterns[:uppercase] = '[[:upper:]]'
    			@patterns[:lowercase] = '[[:lower:]]'
    			@patterns[:letter] = '[[:alpha:]]'
    			@patterns[:alphanumeric] = '[[:alnum:]]'
    			@patterns[:whitespace] = '[[:space:]]'

# new patterns
#
			@patterns[:hexdigit] = '[[:xdigit:]]'
			@patterns[:punctuation] = '[[:punct:]]'
			@patterns[:control] = '[[:cntrl:]]'
			
		end

end

puts ""
puts "Regexify"
puts ""

puts "\t" + Regexify.new
  .begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .end_with('!').to_s
  
puts ""
puts "RegexifyWithOptions"
puts ""

t = RegexifyWithOptions.new
puts "\t1. " + "Options = nil"
puts "\t   " + t.begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .end_with('!').regex.to_s
puts ""
t = RegexifyWithOptions.new('im')
puts "\t2. " + "Options = #{t.options}"
puts "\t   " + t.begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .end_with('!').regex.to_s
puts ""
t = RegexifyWithOptions.new('x')
puts "\t3. " + "Options = #{t.options}"
puts "\t   " + t.begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .end_with('!').regex.to_s
puts ""
begin
	t = RegexifyWithOptions.new('foo')
rescue Regexify::Error => e1
	puts "\t4. " + "Regexify::Error => #{e1}"
end
puts ""
begin
	t = RegexifyWithOptions.new(1)
rescue Regexify::Error => e2
	puts "\t5. " + "Regexify::Error => #{e2}"
end

  
puts ""
puts "RegexifyWithAnchor"
puts ""

puts "\t" + RegexifyWithAnchor.new
  .begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .anchor('b')
  .pos_look_ahead("boy")
  .anchor('Z')
  .neg_look_behind("howdy")
  .end_with('!').to_s

puts ""
puts "RegexifyANSI"
puts ""

puts "\t" + RegexifyANSI.new
  .begin_with(:uppercase, exactly: 3)
  .then(:number, '-', range: [2,10])
  .not(:alphanumeric, exactly:1)
  .then(:hexdigit)
  .then(:punctuation)
  .end_with('!').to_s

puts ""

