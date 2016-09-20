require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'
require 'yaml'

module Margin
  module_function

  # Char & line definitions --------------------

  CHAR = {
    r_d:     "\u250e".encode('utf-8').yellow,
    d_r:     "\u2514".encode('utf-8').yellow,
    r:       "\u2500".encode('utf-8').yellow,
    d:       "\u2502".encode('utf-8').green,
    l_r_d:   "\u252c".encode('utf-8').yellow,
    dbl_r:   "\u2550".encode('utf-8').green,
    dbl_d_r: "\u2558".encode('utf-8').green,
    dbl_u_d_r: "\u255e".encode('utf-8').green,
    dbl_r_d: "\u2564".encode('utf-8').green,
    rnd_d_r: "\u2570".encode('utf-8').yellow,
    rnd_r_d: "\u256d".encode('utf-8').yellow,
    pr_stop: "\u2509".encode('utf-8').green,
  }
  
  LINES = {
    push:    CHAR[:r_d] + CHAR[:r] * 10,
    process: CHAR[:dbl_u_d_r] + CHAR[:dbl_r] + 
      CHAR[:dbl_r_d] + CHAR[:dbl_r] * 5 + CHAR[:pr_stop],
    process2: CHAR[:d] + ' ' + CHAR[:dbl_d_r] + CHAR[:dbl_r] + 
      CHAR[:dbl_r_d] + CHAR[:dbl_r] * 5 + CHAR[:pr_stop],
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
    str = CHAR[:rnd_d_r] + CHAR[:r] + CHAR[:l_r_d]
    (margin).times { str << CHAR[:r] * 2 }
    str << CHAR[:pr_stop] << " push #{val.first}"
    puts str.yellow
  end
  
  def print_pop(margin, val)
    str = ''
    (val[1] - 1).times { str << '  '} unless val[0].is_a? String
    str << CHAR[:rnd_d_r]
    margin.times { str << CHAR[:pr_stop] * 2 }
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
