#! /usr/bin/env ruby

require 'trollop'
require 'colorize'

# Prints all Unicode 25xx characters
class UnicodeTest
  START = "\u2500".ord.freeze
  FIN   = "\u257F".ord.freeze
  GROUPS = {
    straight_h: [
      "\u2500", "\u2501", "\u2508", "\u2509", "\u254c", "\u254d",
      "\u2550", "\u2574", "\u2576", "\u257c", "\u257e"
    ],
    straight_v: [
      "\u2502", "\u2503", "\u2506", "\u2507", "\u250a", "\u250b",
      "\u254e", "\u254f", "\u2551", "\u2579", "\u257b", "\u257d",
      "\u257f"
    ],
    t_section_r: [
      "\u251c", "\u251d", "\u251e", "\u251f", "\u2520", "\u2520",
      "\u2521", "\u2522", "\u2523", "\u255e", "\u255f", "\u2560",
      "\u2560"
    ],
    t_section_d: [
      "\u252d", "\u252e", "\u252f", "\u2530", "\u2531", "\u2532",
      "\u2533", "\u2564", "\u2565", "\u2566"
    ],
    elbow_u_r: [
      "\u2514", "\u2515", "\u2516", "\u2517", "\u2558", "\u2559",
      "\u255a", "\u2570"
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
      puts "> #{key}\n".underline
      group.each_with_index do |ch, i|
        printf('%4s', ch)
        print "\n\n" if (i + 1) % @width == 0
      end
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
