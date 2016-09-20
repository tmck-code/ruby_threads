require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'
require 'yaml'

# The class that prints the visual representation of the queue as items are
# produced, consumed and then processed by the workers.
class Margin
  def initialize(max_q_size)
    @limit = max_q_size
    @queue = Array.new(@limit, {})
  end

  # Char & line definitions --------------------

  CHAR = {
    r_d:     "\u250e".encode('utf-8'),
    d_r:     "\u2514".encode('utf-8'),
    r:       "\u2500".encode('utf-8'),
    d:       "\u2502".encode('utf-8').green,
    l_r_d:   "\u252c".encode('utf-8'),
    dbl_r:   "\u2550".encode('utf-8').green,
    dbl_d_r: "\u2558".encode('utf-8').green,
    dbl_u_d_r: "\u255e".encode('utf-8').green,
    dbl_r_d: "\u2564".encode('utf-8').green,
    rnd_d_r: "\u2570".encode('utf-8'),
    rnd_r_d: "\u256d".encode('utf-8'),
    pr_stop: "\u2509".encode('utf-8').green
  }.freeze

  LINES = {
    process: CHAR[:dbl_u_d_r] + CHAR[:dbl_r] +
             CHAR[:dbl_r_d] + CHAR[:dbl_r] * 5 + CHAR[:pr_stop],
    process2: CHAR[:d] + ' ' + CHAR[:dbl_d_r] + CHAR[:dbl_r] +
              CHAR[:dbl_r_d] + CHAR[:dbl_r] * 5 + CHAR[:pr_stop]
  }.freeze

  # Queue action methods -----------------------

  def print_margin(type, val, q_size)
    case type
    when :push    then print_push(q_size, val)
    when :pop     then print_pop(q_size, val)
    when :process then print_process(q_size, val)
    end
  end

  def print_push(margin, val)
    str = create_push_margin(margin).join + " push #{val.first}"
    puts str.yellow
  end

  def create_push_margin(margin)
    length = margin + 3 # initial gutter, middle char, and final char
    str = Array.new(length, CHAR[:r])
    str[0] = CHAR[:d_r]
    str[margin + 1] = CHAR[:l_r_d]
    str[-1] = CHAR[:pr_stop]
    str
  end

  def create_pop_margin(margin)
  end

  def print_pop(margin, val)
    str = CHAR[:d] + ''
    (val[1] - 1).times { str << '  ' } unless val[0].is_a? String
    str << CHAR[:d_r]
    margin.times { str << CHAR[:pr_stop] * 2 }
    str << ' ' << "pop #{val[0]}".underline
    puts str
  end

  def print_process(margin, val)
    str = CHAR[:d]
    (margin - 1).times { str << CHAR[:r] * 2 }
    str << CHAR[:pr_stop] << "process #{val.first}"
    puts str.green
  end
end
