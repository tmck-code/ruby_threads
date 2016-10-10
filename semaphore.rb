#!/etc/bin/env ruby

require 'thread'
require 'trollop'

# A minimal-ish demonstration of the Ruby Mutex class
class Semaphore
  EOQ = :end_of_queue # Marker for the end of the queue

  def initialize(args)
    @n_threads = 5
    @delay     = 1
    @queue = SizedQueue.new(100) # Max 100 items
    @semaphore = Mutex.new
    @infile = args[:infile]

    print "> Using #{@n_threads} threads\n"
  end

  def run
    print "! PRODUCER STARTING\n"
    t1 = Thread.new { producer }

    t2 = Array.new(@n_threads) do |n|
      Thread.new { worker(n) }
    end

    t1.join
    print "\n! PRODUCER EXITING, pushed #{EOQ}\n\n"

    t2.each(&:join)
    print "\n> Process complete!\n"
  end

  def producer
    20.times do |i|
      payload = (rand * 26).to_i
      sleep 0.1 # Simulate preprocessing

      print "> pushing ##{i}: #{payload}\n"
      @queue.push payload
    end
    @queue.push EOQ # Add the EOQ
  end

  def worker(id)
    print "> WORKER #{id} STARTED\n"
    loop do
      if (payload = @queue.pop) == EOQ
        @queue.push EOQ
        break
      end
      @semaphore.synchronize { work(payload, id) }
      sleep @delay # Rate limit
    end
    print ">>WORKER #{id} EXITING\n"
  end

  def work(payload, id)
    puts "worker #{id} using file"
    line = ""
    File.open(@infile, 'r').each_with_index do |l, i|
      next if i < payload
      line = l.strip
      break
    end
    print ">>worker #{id} done: #{[payload, line]}\n"
  end
end

args = Trollop.options do
  opt :infile, 'The input file', type: :string,
      required: true
end
Semaphore.new(args).run
