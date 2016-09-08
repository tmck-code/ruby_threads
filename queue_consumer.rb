require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'

module Margin
  module_function
  
  def print_margin(type, val, queue_size)
    str = "#{type} #{val}"
    str =
      case type
      when :push    then print_push(queue_size, str)
      when :pop     then print_pop(queue_size, str)
      when :process then print_process(queue_size, str)
      end
  end

  def print_push(margin, msg)
    str = ''
    (margin - 1).times { str << '|' }
    str << '-' << msg
    puts str.yellow
  end
  
  def print_pop(margin, msg)
    str = '\\'
    (margin - 1).times { str << '_' }
    str << msg
    puts str.underline
  end
  
  def print_process(margin, msg)
    str = ''
    (margin - 1).times { str << ' ' }
    str << '-' << msg
    puts str.green
  end
end

class LifeKey
  attr_reader :queue
  EOQ = :end_of_queue

  # WORKER INNER CLASS ------------------------------------

  class Task
    def initialize(message)
      @message = message
      puts "Worker: #{@message}".green
    end

    def work(obj, queue_size)
      Timeout.timeout(5) do
        sleep(rand * 7)
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
    sleep rand * 10

    @n_threads.times { |n| consumer(n) }

    sleep rand

    t1.join
    @workers.each(&:join)
  end

  # FILL QUEUE WITH ITEMS ---------------------------------

  def producer
    Thread.new do
      @limit.times do |i|
        check_queue_size
        Margin.print_margin(:push, i, @queue.size)
        @queue << i

        sleep rand
      end
      @queue << EOQ
      print "Producer exiting\n"
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
      Margin.print_margin(:pop, 'consumer', @queue.size)
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
