#! /usr/bin/env ruby

require 'yaml'
require 'json'

# Takes user input and creates a hash of the characteristics for each
# unicode box-drawing char
class Characteristics
  START = "\u2500".ord.freeze
  FIN   = "\u257F".ord.freeze

  OPTIONS = {
    th:  :thin,
    s:   :solid,
    dbl: :dbl,
    d:   :dotted,
    r:   :round,
    t:   :t_section,
    e:   :elbow,
    v:   :v_straight,
    h:   :h_straight
  }.freeze

  def initialize
    @chars = (START..FIN).each_with_object({}) do |n, h|
      h[n] = {
        symbol: [n].pack('U*'),
        options:
          OPTIONS.keys.each_with_object({}) do |(key, _v), hash|
            hash[key] = false
          end
      }
    end
  end

  def generate
    info
    (START..FIN).each { |char| get_options(char) }
  end

  def info
    puts '> All chars:'
    puts CHARS
    puts '> All options:'
    puts JSON.pretty_generate(OPTIONS)
  end

  def get_options(char)
    loop do
      break if (opt = STDIN.gets.strip == 'p')
      puts "options: "
      opt = STDIN.gets.strip
      next if OPTIONS[opt].nil?
      @chars[char]
    end
  end
end

Characteristics.new.generate if $PROGRAM_NAME == __FILE__
