require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'

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
        sleep(rand * 2)
        (queue_size).times { print '.' }
        puts "-- processing #{obj}".black.on_green
      end
    rescue Timeout::Error
      puts "* caught!! #{obj}".yellow
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

    sleep 3

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
        (@queue.size).times { print '>' }
        puts "Pushing #{i}"

        @queue << i
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
      puts "Started consumer #{n}"
      worker = Task.new(n)
      loop do
        if (payload = @queue.pop) == EOQ
          puts '> EOQ detected'
          break
	end

        (@queue.size).times { print '_' }
        print "- #{n} popped #{payload}\n\n"

        @workers.push Thread.new { worker.work(payload, @queue.size) }
        sleep rand
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
