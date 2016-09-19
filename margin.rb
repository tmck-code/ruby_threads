require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'
require 'yaml'

module Margin
  module_function

  # Char & line definitions --------------------

  CHARS = {
    r_d:     "\u250e".encode('utf-8').yellow,
    d_r:     "\u2516".encode('utf-8').yellow,
    r:       "\u2500".encode('utf-8').yellow,
    dbl_r:   "\u2550".encode('utf-8').green,
    dbl_d_r: "\u2558".encode('utf-8').green,
    rnd_d_r: "\u2570".encode('utf-8').blue,
    rnd_r_d: "\u256d".encode('utf-8').yellow,
  }
  
  LINES = {
    process: CHARS[:r_d] + CHARS[:r] * 10
  }.freeze
  
  # Queue action methods -----------------------
  
  def print_margin(type, val, q_size)
    str =
      case type
      when :push    then print_push(q_size, val)
      when :pop     then print_pop(q_size, val)
      when :process then print_process(q_size, val)
      end
  end

  def print_push(margin, val)
    str = '| '
    (margin).times { str << '| ' }
    str << '-' << "push #{val.first}"
    puts str.yellow
  end
  
  def print_pop(margin, val)
    str = ''
    (val[1] - 1)
    .times { str << '  '} unless val[0].is_a? String
    str << '\\ '
    margin.times { str << '| ' }
    str << "pop #{val[0]}".underline
    puts str
  end
  
  def print_process(margin, val)
    str = ''
    (margin - 1).times { str << '__' }
    str << '-' << "process #{val.first}"
    puts str.green
  end
end
