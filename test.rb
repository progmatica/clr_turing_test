#!/usr/bin/env ruby 

# == Synopsis 
#   This is a Turing Test.  Of course, a Turing Test traditionally requires a 
#     human subject to act as the human; however, that is highly inefficient 
#     and unreliable.  We automate the human actor in the Turing Test below.
#
# == Usage
#   This command runs the test:
#     ruby test.rb
#
#   And this command runs the test against an included contender:
#     ruby test.rb --autorespond
#
# == Sample Output
#
# >$ ruby test.rb -f
# what's your name?
# > casey
# yo.
#   --anyway, hate to cut this short, but my watch
#  is giving me trouble, so I just have one question
#  -- what's the answer to the following:
# > uh
# IV - III
# > II
# ack -- that means I'm late -- gotta run -- sucker!
# CONGRATULATIONS! YOU PASSED THE TURING TEST.
# > ok
#
# == Options
#   -r, --autorespond       Calls the included contender.
#   -f, --fast          Puts a fire under the 'human' fingers.
#   -h, --help          Displays help message.
#   -v, --version       Display the version, then exit.
#   -V, --verbose       Outputs verbosely.
#
# == Author
#   CLR
#
# == Copyright
#   Copyright (c) 2008 CLR. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse' 
require 'rdoc/usage'
require 'ostruct'
require 'date'
require 'open3'
require 'lib/roman_numeral' 

FILE_FEMALE_FIRST_NAMES = 'data/female_firstnames.txt'
FILE_MALE_FIRST_NAMES = 'data/male_firstnames.txt'
FILE_LAST_NAMES = 'data/lastnames.txt'
AUTORESPONDER_COMMAND = 'ruby contender.rb ; echo $? 1>&2'

class Test
  VERSION = '0.0.1'
  
  attr_reader :options

  def initialize( arguments, stdin )
    @arguments = arguments
    @stdin = stdin
    @stdout = $stdout
    $, = ""
    $\ = "\n"
    @female_first_names = NameList.new( FILE_FEMALE_FIRST_NAMES )
    @male_first_names = NameList.new( FILE_MALE_FIRST_NAMES )
    @last_names = NameList.new( FILE_LAST_NAMES )
    
    # Set defaults
    @options = OpenStruct.new
    @options.verbose = false
  end

  # Parse options, check arguments, then process the command
  def run
        
    if parsed_options? && arguments_valid? 
      
      puts "Start at #{ DateTime.now }\\n\\n" if @options.verbose
      output_options if @options.verbose
            
      process_options
      
      step_one
      step_two
      step_three
      step_four
      
      puts "\\nFinished at #{ DateTime.now }" if @options.verbose
      
    else
      output_usage
    end
      
  end
  
  protected
  
    def parsed_options?
      
      # Specify options
      opts = OptionParser.new 
      opts.on( '-r', '--autorespond' )  { @options.autorespond = true }
      opts.on( '-f', '--fast' )         { @options.fast = true }
      opts.on( '-v', '--version' )      { output_version ; exit 0 }
      opts.on( '-h', '--help' )         { output_help }
      opts.on( '-V', '--verbose' )      { @options.verbose = true }  
      # TO DO - add additional options
            
      opts.parse!(@arguments) rescue return false
      true      
    end

    def process_options
      @contender = Open3.popen3( AUTORESPONDER_COMMAND ) if @options.autorespond
    end
    
    def output_options
      puts "Options:\\n"
      
      @options.marshal_dump.each do |name, val|        
        puts "  #{name} = #{val}"
      end
    end

    # True if required arguments were provided
    def arguments_valid?
      true
    end
    
    def output_help
      output_version
      RDoc::usage() #exits app
    end
    
    def output_usage
      RDoc::usage('usage') # gets usage from comments above
    end
    
    def output_version
      puts "#{File.basename(__FILE__)} version #{VERSION}"
    end
    
    def step_one
      say "what's your name?" 
      input = listen
      case input
        when /f|Four/
          fail "nice try -- that's a number, not a name."
        when @male_first_names # Have to check male names first, because female names are too inclusive.
          say "yo."
        when @female_first_names
          say "f? ..."
        when @last_names
          say "i meant your first name ..."
        else
          fail "that's doesn't sound like a name to me."
      end
    end

    def step_two
      say "--anyway, hate to cut this short, but my watch is giving me trouble, so I just have one question for you -- what's the answer to the following Roman Numeral arithmetic:" 
      input = listen
    end

    def step_three
      @numeral_one = [ 
        RomanNumeral.new( "VII" ),
        RomanNumeral.new( "VIII" ),
        RomanNumeral.new( "IX" ),
        RomanNumeral.new( "X" ),
        RomanNumeral.new( "XI" ),
        RomanNumeral.new( "XII" )
      ][ rand( 6 ) ]
      @numeral_two = [ 
        RomanNumeral.new( "I" ),
        RomanNumeral.new( "II" ),
        RomanNumeral.new( "III" ),
        RomanNumeral.new( "IV" ),
        RomanNumeral.new( "V" ),
        RomanNumeral.new( "VI" )
      ][ rand( 6 ) ]
      @numeral_two = RomanNumeral.new( "III" )
      say "#{ @numeral_one } - #{ @numeral_two }"
      @answer = @numeral_one - @numeral_two
      input = listen
      case input
        when /#{ @answer }/
          pass %w(shoot shucks ack)[ rand( 3 ) ] + " -- that means I'm late -- gotta run -- " + %w(later! peace.  sucker!)[ rand( 3 ) ]
        else
          fail "wrong! what did you miss that class in fifth grade?"
      end
    end

    def step_four
      input = listen
    end

    def say( output )
      if @contender 
        output.each_char do |c|
          sleep( rand / 3 ) unless @options.fast
          @stdout.write_nonblock( c )
        end
        @stdout.write( "\n" )
        @contender[0].puts output
      else
        output.each_char do |c|
          sleep( rand / 3 ) unless @options.fast
          @stdout.write_nonblock( c )
        end
        @stdout.write( "\n" )
      end
    end

    def pass( output )
      say output
      say "CONGRATULATIONS! YOU PASSED THE TURING TEST."
    end

    def fail( output )
      say output
      say "YOU FAILED THE TURING TEST."
      exit 0
    end

    def listen
      if @contender
        answer = @contender[1].gets
        @stdout.write( "> #{ answer }" )
        return answer
      else
        @stdout.write( "> " )
        gets
      end
    end
end


class NameList < Array

  def initialize( file_name )
    File.new( file_name, "r" ).readlines.each do |line|
      self << line.strip
    end
  end
  
  def ===( word )
    words = word.gsub( /[^\w| ]/, '' ).upcase.squeeze( " " ).split( " " )
    !( self & words ).empty?
  end
end

# Run the application
app = Test.new( ARGV, STDIN )
app.run
