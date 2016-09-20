#! /usr/bin/env ruby

require 'trollop'
require 'colorize'

# Prints all Unicode 25xx characters
class UnicodeTest
  START = "\u2500".ord.freeze
  FIN   = "\u257F".ord.freeze
  GROUPS = {
    ch_straight: [
      "\u2500", "\u2501", "\u2508", "\u2509", "\u254c", "\u254d",
      "\u2550", "\u2574", "\u2576", "\u257c", "\u257e"
    ],
    t_section_r: [
      "\u251c", "\u251d", "\u251e", "\u251f", "\u2520", "\u2520",
      "\u2521", "\u2522", "\u2523", "\u255e", "\u255f", "\u2560",
      "\u2560"
    ]
  }.freeze

  def initialize(args)
    @width = args[:width] || 16
    @type =  args[:type]
  end

  def run
    case @type
    when :seq   then print_seq
    when :group then print_groups
    else raise "run-type error, must be :seq or :group, was <#{@type}"
    end
  end

  def print_seq
    n = START
    loop do
      row_fin = n + @width
      (n..row_fin).each { |curr| print_hex(curr) }
      puts
      (n..row_fin).each { |curr| print_unicode(curr) }
      puts "\n\n"
      n = row_fin
      break if n >= FIN
    end
  end

  def print_hex(n)
    printf('%04x   ', n)
  end

  def print_unicode(n)
    print format('%04s   ', [n].pack('U*')).yellow
  end

  def print_groups
    GROUPS.each do |key, group|
      puts "> #{key}"
      group.each { |ch| printf('%2s', ch) }
      puts "\n\n"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  args = Trollop.options do
    opt :width, 'The max no. of chars printed per row', type: :integer
    opt :groups, 'Print the box-drawing characters grouped by direction'
  end

  args[:type] = args.groups.nil? ? :seq : :group
  UnicodeTest.new(args).run
end
