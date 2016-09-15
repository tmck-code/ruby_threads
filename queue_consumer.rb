require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'

module Margin
  module_function
  
  def print_margin(type, val, queue_size)
    str = 
    str =
      case type
      when :push    then print_push(queue_size, val)
      when :pop     then print_pop(queue_size, val)
      when :process then print_process(queue_size, val)
      end
  end

  def print_push(margin, val)
    str = '|'
    (margin).times { str << '| ' }
    str << '-' << "push #{val.first}"
    puts str.yellow
  end
  
  def print_pop(margin, val)
    str = ''
    val[1].times { str << ' '} unless val[0].is_a? String
    str << '\\'
    (margin - 1).times { str << '| ' }
    str << "pop #{val[0]}".underline
    puts str
  end
  
  def print_process(margin, val)
    str = ''
    (margin - 1).times { str << ' ' }
    str << '-' << "process #{val.first}"
    puts str.green
  end
end

class LifeKey
  attr_reader :queue
  EOQ = :end_of_queue

  # WORKER INNER CLASS ------------------------------------

  class Task
    def initialize(id)
      @id = id.to_i
    end
    def work(obj, queue_size)
      Timeout.timeout(5) do
        sleep(rand * 3)
        Margin.print_margin(:process, obj, queue_size)
      end
    rescue Timeout::Error
      puts "* caught!! #{obj}".red
    end
  end

  # MAIN CLASS --------------------------------------------

  def initialize(args)
    @n_threads = args[:n_threads] || 2
    @limit     = args[:limit]     || 10
    puts "Using #{@n_threads} threads" 
    @queue = Queue.new
    @queue_size = args[:queue_size] || 10
    @workers = []
  end

  def run
    t1 = producer
    sleep rand

    @n_threads.times { |n| consumer(n) }

    sleep 1

    t1.join
    @workers.each(&:join)
  end

  # FILL QUEUE WITH ITEMS ---------------------------------

  def producer
    Thread.new do
      @limit.times do |i|
        check_queue_size
        payload = [i, @queue.size + 1]
        Margin.print_margin(:push, payload, @queue.size)

        @queue << payload
      end
      @queue << EOQ
      puts "Producer exiting"
    end
  end
  
  # Checks if the queue has more items than the allowed limit, waits if true
  def check_queue_size
    loop do
      break if @queue.empty? || @queue.size <= @queue_size
      puts "queue is #{@queue.size}"
      sleep 0.1
    end
  end

  # CONSUME FROM QUEUE AND THREAD -------------------------

  def consumer(n)
    Thread.new do
      puts "consumer #{n}"
      worker = Task.new(n)
      loop do
        break if (payload = @queue.pop) == EOQ
        Margin.print_margin(:pop, payload, @queue.size)

        @workers.push Thread.new { worker.work(payload, @queue.size) }
        sleep rand * 2
      end
      print "Consumer exiting\n"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  args = Trollop.options do
    opt :n_threads, 'The number of consumer threads', type: :integer
    opt :limit, 'The number of ints to loop through', type: :integer
    opt :queue_size, 'The maximum queue size', type: :integer
  end

  LifeKey.new(args).run
end
