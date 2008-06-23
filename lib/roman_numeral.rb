# Roman Numeral test class: My Dear Cat Loves eXtra Vitamins Intensely.
#
# From the test description:
# This class extends a string, treats itself as though it is a Roman Numeral,
# allows simple arithmetic with other objects of type RomanNumeral, and returns 
# the result as a Roman Numeral.
#
# There are two ways to approach this problem.  The first, and probably
# more reasonable approach, is to parse the Roman numerals into decimal, and then carry out
# arithmetic using Ruby's integer operators, then convert the result back into a Roman numeral.
#
# The second approach is to carry out the arithmetic with character substitutions,
# the way the Romans did.  I just finished reading Gibbon's _Fall and Decline
# of the Roman Empire_.  In celebration of this book, I took the second, authentic route.
#
# That's right: the following code uses no decimal or integer arithmetic.  It's all done
# with regex and character substitution, the only way the Romans knew how.  (Regex was
# very popular in the late empire.)
#
# The following is perfectly valid:
#
# irb> @a = RomanNumeral.new("X")
# irb> @b = RomanNumeral.new("L")
# irb> @c = RomanNumeral.new("MCMLXXXVIII")
# irb> @d = RomanNumeral.new("MLXVI")
# irb> @c - @d + @a
# => "CMXXXII"
#
# Or try:
# irb> RomanNumeral.self_test
# 
# Of course, errors are raised if a larger number is subtracted from smaller one, (Romans didn't
# have negative), a numeral isn't Roman, etc.
#
# Enjoy!


class RomanNumeral < String
  ROMAN_CHARS = "IVXLCDM"
  ERROR_ILLEGAL_SUBTRACTION = "Cannot subtract a larger Roman Numeral from a smaller one!"
  ERROR_ILLEGAL_COMPARISON = "Comparison requires two Roman Numerals!"

  # A RomanNumeral is based on String, with basic checking to make sure the characters are in the proper set.
  def initialize(numeral)
    bad_char = /[^#{ROMAN_CHARS}]+/.match(numeral)
    if bad_char
      raise "Could not instantiate numeral: Position " + bad_char.begin(0).to_s + " in the string is an illegal character '" + bad_char.to_s + "'!"
    end
    super
  end

  # This class function parses an expression written using Roman numerals. This generally isn't needed,
  # since objects of type RomanNumeral know how to dance with each other anyway.
  def self.parse_expression( expression, forgiving = false )
    unless forgiving
      expression.gsub!( / /, "" )
      return false unless RomanNumeral.verify_expression(expression)
    else
      expression.gsub!( /[^\+\-#{ROMAN_CHARS}]+/, "" )
    end
    if expression =~ /[\-\+]/
      operator = expression.rindex(/[\-\+]/)
      if expression[operator,1] == "+"
         RomanNumeral.parse_expression(expression[0..(operator - 1)]) + RomanNumeral.parse_expression(expression[(operator + 1)..(expression.length - 1)])
      elsif expression[operator,1] == "-"
         RomanNumeral.parse_expression(expression[0..(operator - 1)]) - RomanNumeral.parse_expression(expression[(operator + 1)..(expression.length - 1)])
      else
        raise "Function 'rindex' is broken!"
      end
    else
      return RomanNumeral.new(expression)
    end
  end

  # Sanity check that the expression is properly formed.
  def self.verify_expression(expression)
    raise "Expression cannot be empty!" if (expression.nil? or expression.empty?)
    bad_char = /[^\+\-#{ROMAN_CHARS}]+/.match(expression)
    raise "Position " + bad_char.begin(0).to_s + " in the string is an illegal character '" + bad_char.to_s + "'!" if bad_char
    raise "Epression cannot begin with an operater!" if expression =~ /(^[\+\-])/
    raise "Epression cannot end with an operater!" if expression =~ /([\+\-]$)/
    return true
  end

  # Call RomanNumeral.self_test to get a preview of the action.
  def self.self_test
    @trajan = RomanNumeral.new("CXVII")
    @fall = RomanNumeral.new("CDLXXVI")
    @now = RomanNumeral.new("MMVI")
    @turks = RomanNumeral.new("MCDLII")
    @usday = RomanNumeral.new("MDCCLXXVI")
    @ww2 = RomanNumeral.new("MCMXLV")
    print <<-END_RANT
      The Roman empire was at its greatest extent under Trajan in the year #{@trajan}. The empire fell in
      #{@fall}, meaning it had #{@fall - @trajan} years of decline.  The current year is #{@now}, so the
      peak was #{@now - @trajan} years ago, and the fall was #{@now - @fall} years ago.  Roman culture continued
      in the Byzantine Empire until #{@turks}, which was an additional #{@turks - @fall} years.  This was
      #{@now - @turks} years ago.  So overall, Roman culture was in decline for #{@fall - @trajan + @turks - @fall}
      years.  The U.S., born in #{@usday}, has only existed #{@now - @usday} years.  Since we probably maxed out
      during WWII, which was #{@ww2}, we've only had #{@now - @ww2} years of cultural decline.  So celebrate --
      because we have a long way to go if global warming doesn't kill us first!
    END_RANT
  end

  # Converts a Roman numeral to its additive form, such that IV -> IIII
  def to_add
    new_numeral = self.dup
    ROMAN_CHARS.each_char do |char|
      allowed_subtrahends = lower_chars(char)[-2,2] || lower_chars(char)[-1,1] || "N"
      subtractive = /([#{allowed_subtrahends}]+)([#{char}])/.match(new_numeral)
      if subtractive
        new_numeral = subtractive.pre_match << ( RomanNumeral.new(subtractive[2]).minus( RomanNumeral.new(subtractive[1]) ) ) << subtractive.post_match
      end
    end
    RomanNumeral.new(new_numeral)
  end

  # Converts a Roman numeral to its subtractive form, such that IIII -> IV
  def to_sub
    new_numeral = self.dup.to_add.denumerate
    # First, look for second-order substitutions, like VIIII => IX
    ROMAN_CHARS.each_char do |char|
      first_order = lower_chars(char)[-1,1] || "N"
      second_order = lower_chars(char)[-2,1] || "N"
      new_numeral.sub!(/[#{first_order}][#{second_order}]{4}/, second_order << char)
    end
    # Second, look for single-order substitutions, like IIII => IV
    ROMAN_CHARS.each_char do |char|
      first_order = lower_chars(char)[-1,1] || "N"
      new_numeral.sub!(/[#{first_order}]{4}/, first_order << char)
    end
    RomanNumeral.new(new_numeral)
  end

  # Roman numeral addition in standard (subtractive) form.
  def +(addend)
    self.plus(addend).to_sub
  end
  # Roman numeral addition in additive form.
  def plus(addend)
    augend = self.dup.to_add
    addend = addend.to_add
    summand = ""
    ROMAN_CHARS.each_char do |char|
      augend.scan(/[#{char}]/) do |x|
        summand << x
      end
      addend.scan(/[#{char}]/) do |x|
        summand << x
      end
    end
    RomanNumeral.new(summand.reverse)
  end

  # Roman numeral subtraction in standard (subtractive) form.
  def -(subtrahend)
    self.minus(subtrahend).to_sub
  end
  # Roman numeral subtraction in additive form.
  def minus(subtrahend)
    minuend = self.dup.to_add
    subtrahend = subtrahend.to_add
    ROMAN_CHARS.each_char do |char|
      while minuend.send("has_less_#{char}_than", subtrahend)
        minuend = minuend.borrow_for(char)
      end
    end
    difference = minuend
    subtrahend.each_char do |char|
      difference.sub!(char, "")
    end
    RomanNumeral.new(difference)
  end

  # Returns the Roman numeral characters higher than that given.
  def higher_chars(char)
    ROMAN_CHARS.split(char)[1]
  end
  # Returns the Roman numeral characters lowel than that given.
  def lower_chars(char)
    ROMAN_CHARS.split(char)[0]
  end
  # Borrow for more of the type of character given; such as, X -> VV given V.
  def borrow_for(char)
    new_numeral = self.dup
    while( !new_numeral.send("has_more_#{char}_than", self) )
      raise ERROR_ILLEGAL_SUBTRACTION unless higher_chars(char)
      borrow_from = /[#{higher_chars(char)}]/.match(new_numeral.reverse)
      raise ERROR_ILLEGAL_SUBTRACTION unless borrow_from
      new_numeral = borrow_from.post_match.reverse << enumerate(borrow_from[0]) << borrow_from.pre_match.reverse
    end
    RomanNumeral.new(new_numeral)
  end

  # Enumerate the character to the next smaller denomination.
  def enumerate( char )
    raise "An illegal character (" + char + ") was entered!" unless RomanNumeral.equivalents.has_key?(char)
    RomanNumeral.equivalents[char]
  end

  # Denumerate the numeral so that smaller characters are consolidated.
  def denumerate
    denumerated = self.dup
    RomanNumeral.equivalents.each do |key, value|
      denumerated.gsub!( value, key )
    end
    RomanNumeral.new( denumerated )
  end

  # Method missing provides comparisons for RomanNumerals; such as, "XIII".has_more_I_than("XII") => true
  # or "MCM".has_equal_D_as("DDVII") => false
  def method_missing(method, *args, &block)
    if match = /has_less_([#{ROMAN_CHARS}])_than/.match(method.to_s)
      raise ERROR_ILLEGAL_COMPARISON unless args[0].is_a?(RomanNumeral)
      char = match[0]
      self.count(char) < args[0].count(char)
    elsif match = /has_equal_([#{ROMAN_CHARS}])_as/.match(method.to_s)
      raise ERROR_ILLEGAL_COMPARISON unless args[0].is_a?(RomanNumeral)
      char = match[0]
      self.count(char) == args[0].count(char)
    elsif match = /has_more_([#{ROMAN_CHARS}])_than/.match(method.to_s)
      raise ERROR_ILLEGAL_COMPARISON unless args[0].is_a?(RomanNumeral)
      char = match[0]
      self.count(char) > args[0].count(char)
    else
      super
    end
  end

  def self.equivalents
    { "V" => "IIIII",
      "X" => "VV",
      "L" => "XXXXX",
      "C" => "LL",
      "D" => "CCCCC",
      "M" => "DD"
    }
  end
end


class String
  # This function should already exist, as indicated at: http://www.ruby-doc.org/core/
  # However, it does not exist in my runtime, so I duplicate it here.
  # Update - this vacuity is a noted bug: http://blog.nicksieger.com/articles/2006/10/22/rubyconf-i18n-m17n-unicode-and-all-that
  def each_char
    scan(/./) do |x|
      yield(x)
    end
  end
end

