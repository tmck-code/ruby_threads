require 'trollop'
require 'thread'

class LifeKey
  EOQ = :end_of_queue

  def initialize(args)
    @n_threads = args[:n_threads] || 2
    puts "Using #{@n_threads} threads" 
    @queue = Queue.new
  end

  def run
    t1 = Thread.new { producer }
    consumers = @n_threads.times.map do |n|
      Thread.new { consumer(n) }
    end.each(&:join)
    t1.join
  end

  def producer
      5.times do |i|
        puts "Pushing #{i}"
        @queue << i
        sleep 1
      end
      @queue << EOQ
      p 'Producer exiting'
  end

  def consumer(n)
    puts "Started consumer #{n}"
      loop do
        payload = @queue.pop
        break if payload == EOQ
        print "- #{n} popped #{payload}\n\n"
        sleep 2
      end
      p 'Consumer exiting'
  end
end

if $PROGRAM_NAME == __FILE__
  args = Trollop.options do
    opt :n_threads, 'The number of consumer threads', type: :integer
  end

  LifeKey.new(args).run
end
