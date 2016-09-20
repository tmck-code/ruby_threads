#! /usr/bin/env ruby

require 'trollop'
require 'colorize'

# Prints all Unicode 25xx characters
module UnicodeTest
  module_function

  START = "\u2500".ord.freeze
  FIN   = "\u257F".ord.freeze

  def run(width)
    width ||= 16
    n = START
    loop do
      row_fin = n + width
      (n..row_fin).each { |curr| print_hex(curr) }
      puts
      (n..row_fin).each { |curr| print_unicode(curr) }
      puts "\n"
      n = row_fin
      break if n >= FIN
    end
  end

  def print_hex(n)
    printf('%04x | ', n)
  end

  def print_unicode(n)
    print format('%04s | ', [n].pack('U*')).yellow
  end
end

if $PROGRAM_NAME == __FILE__
  args = Trollop.options do
    opt :width, 'The max no. of chars printed per row', type: :integer
  end
  UnicodeTest.run(args.width)
end
