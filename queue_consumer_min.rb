#!/usr/bin/env ruby

require 'thread'

# A minimal-ish demonstration of a ruby thread queue.
class ThreadPool
  EOQ = :end_of_queue # Marker for the end of the queue

  def initialize
    @n_threads = 5
    @delay     = 1
    @queue = SizedQueue.new(100) # Max 100 items

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
      payload = (rand * 2).round(2)
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

      work(payload, id)
      sleep @delay # Rate limit
    end
    print ">>WORKER #{id} EXITING\n"
  end

  def work(payload, id)
    print ">>worker #{id} done: #{payload}\n"
    sleep payload
  end
end

ThreadPool.new.run if $PROGRAM_NAME == __FILE__
