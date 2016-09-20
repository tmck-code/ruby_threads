#! /usr/bin/env ruby

require 'colorize'

# Prints all Unicode 25xx characters
module UnicodeTest
  module_function

  START = "\u2500".ord.freeze
  FIN   = "\u257F".ord.freeze

  def run
    (START..FIN).each { |i| puts format('%04x: %s', i, [i].pack('U*').yellow) }
  end
end

UnicodeTest.run if $PROGRAM_NAME == __FILE__
