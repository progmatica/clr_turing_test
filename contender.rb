#!/usr/bin/env ruby 
#
# == Synopsis 
#   This script has one simple goal: to pass the Turing Test that I wrote.
#
# == Author
#   CLR
#
# == Copyright
#   Copyright (c) 2008 CLR. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'lib/roman_numeral' 

FILE_FEMALE_FIRST_NAMES = 'data/female_firstnames.txt'
FILE_MALE_FIRST_NAMES = 'data/male_firstnames.txt'
FILE_LAST_NAMES = 'data/lastnames.txt'

class Contender
  VERSION = '0.0.1'
  
  def initialize
    $, = ""
    $\ = "\n"
    @female_first_names = NameList.new( FILE_FEMALE_FIRST_NAMES )
    @male_first_names = NameList.new( FILE_MALE_FIRST_NAMES )
    @last_names = NameList.new( FILE_LAST_NAMES )
  end

  # Parse options, check arguments, then process the command
  def run
    step_one
    step_two
    step_three
    step_four
  end
  
  protected
  
    def output_version
      puts "#{File.basename(__FILE__)} version #{VERSION}"
    end
    
    def step_one
      listen
      say rand < 0.5 ? @female_first_names[ rand( @female_first_names.length ) ] : @male_first_names[ rand( @male_first_names.length ) ] + ", how's it going? (^_^)"
    end

    def step_two
      listen
      listen
      say %w(yup yeah shoot)[ rand( 3 ) ]
    end

    def step_three
      problem = listen
      say %w(um okay err)[ rand( 3 ) ] + ", it's been a while, but I think that's #{ RomanNumeral.parse_expression( problem, true ) }"
    end

    def step_four
      listen
      say %w(bye. later! dork!)[ rand( 3 ) ]
    end

    def say( output )
      output.each_char do |c|
        sleep( rand / 3 )
      end if false
      puts output
    end

    def listen
      gets
    end
end


class NameList < Array

  def initialize( file_name )
    File.new( file_name, "r" ).readlines.each do |line|
      self << line.strip
    end
  end
  
  def ===( word )
    words = word.upcase.squeeze( " " ).split( " " )
    !( self & words ).empty?
  end
end

# Run the application
app = Contender.new
app.run
