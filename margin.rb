require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'

module Margin
  module_function
  
  def print_margin(type, val, queue_size)
    str =
      case type
      when :push    then print_push(queue_size, val)
      when :pop     then print_pop(queue_size, val)
      when :process then print_process(queue_size, val)
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
