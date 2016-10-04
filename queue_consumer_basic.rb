#!/usr/bin/env ruby
# encoding: utf-8

require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'

require_relative 'margin'

# A minimal working demonstration of a ruby queue producer-consumer.
class LifeKey
  attr_reader :queue
  EOQ = :end_of_queue

  N_THREADS     = 10 # The max amount of workers
  LIMIT_WAITING = 50 # The max amount of queue items waiting for workers
  LIMIT_CURRENT = 50 # The max amount of work items currently in progress
  DELAY         = 1  # The average task response time in seconds.
  TOTAL_ITEMS   = 20 # The number of payloads to produce

  def initialize(args)
    @n_threads     = N_THREADS     || args[:n_threads]
    @limit_waiting = LIMIT_WAITING || args[:limit_waiting]
    @limit_current = LIMIT_CURRENT || args[:limit_current]
    @delay         = DELAY         || args[:delay]
    @total         = TOTAL_ITEMS   || args[:total]

    @queue = Queue.new
    @workers = []

    puts "> Using #{@n_threads} threads"
  end

  # Main method -------------------------------------------

  def run
    t1 = producer

    @n_threads.times { |n| consumer(n) }

    sleep 1

    t1.join
    @workers.each(&:join)
  end

  # Queue methods -----------------------------------------

  def producer
    Thread.new do
      @total.times do |i|
        check_queue_size

        payload = i # Payload is a random digit, just for simplicity

        @queue << payload
      end
      @queue << EOQ # Add the end-of-queue object when we're finished
      puts "\n! Producer exiting\n"
    end
  end

  # Checks if the queue has more items than the allowed limit, waits if true
  def check_queue_size
    loop do
      break if @queue.empty? || @queue.size <= @limit_waiting
      puts "queue is #{@queue.size}"
      sleep 0.05
    end
  end

  # Consume from queue and thread
  def consumer(id)
    Thread.new do
      worker = Task.new(id)
      loop do
        break if (payload = @queue.pop) == EOQ # Break if we're at the end

        @workers.push Thread.new { worker.work(payload) }
        sleep rand * 2
      end
      puts "\n! Consumer exiting\n"
    end
  end

  # Performs the task that all this queueing has been about.
  # Currently, it just sleeps for a random time and returns the milliseconds.
  class Task
    def initialize(id)
      @id = id.to_i
      puts '> initialized worker '.green + id.to_s
    end

    def work(payload)
      Timeout.timeout(5) do
        puts "- worker #{@id}, work: #{payload}"
        sleep(payload)
        puts '>>'.green + "worker #{@id}, done: #{payload}"
      end
    rescue Timeout::Error
      puts '!!'.red + "worker #{@id}, caught: #{payload}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  args = Trollop.options do
    opt :n_threads, 'The number of consumer threads', type: :integer
    opt :total, 'The number of ints to loop through', type: :integer
    opt :queue_size, 'The max amount of queue items waiting for workers',
        type: :integer
    opt :delay, 'Seconds that each worker waits for before the next job',
        type: :integer
  end

  LifeKey.new(args).run
end
