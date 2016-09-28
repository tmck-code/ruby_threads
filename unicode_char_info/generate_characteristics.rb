#! /usr/bin/env ruby

require 'yaml'
require 'json'
require 'pp'

# Takes user input and creates a hash of the characteristics for each
# unicode box-drawing char
class Characteristics
  START = "\u2500".ord.freeze
  FIN   = "\u257F".ord.freeze

  OPTIONS = {
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
      @outfile = 'generated_characteristics.yml'
      Signal.trap("TERM") { shutdown }
    end
  end

  def shutdown
    File.open(@outfile, 'w') { |f| f.write @chars.to_yaml }
    exit
  end

  def generate
    @chars.each_with_index do |(key, char), i|
      puts "#{i}/#{@chars.size}"
      char[:options] = get_options(char)
      puts YAML.dump char[:options]
    end
    puts JSON.pretty_generate(@chars)
  end

  def info
    puts '> All chars:'
    puts @chars
    puts '> All options:'
    puts JSON.pretty_generate(OPTIONS)
  end

  def get_options(char)
    pp OPTIONS
    puts char[:symbol]
    opts = STDIN.gets.strip.split(',')

    return nil if opts.first == 'p'
    shutdown if opts.first == 'exit'
    opts.each_with_object({}) { |o, h| h[o] = true }
  end
end

Characteristics.new.generate if $PROGRAM_NAME == __FILE__
