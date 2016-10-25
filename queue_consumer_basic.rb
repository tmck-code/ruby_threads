#!/usr/bin/env ruby
# encoding: utf-8

require 'trollop'
require 'thread'
require 'timeout'
require 'colorize'

# A minimal working demonstration of a ruby queue producer-consumer.
class LifeKey
  attr_reader :queue

  EOQ = :end_of_queue # Marker for the end of the queue

  N_THREADS     = 10  # The max amount of workers
  LIMIT_WAITING = 50  # The max amount of queue items waiting for workers
  DELAY         = 0.2 # The average task response time in seconds.
  TOTAL_ITEMS   = 200 # The number of payloads to produce
  TIMEOUT       = 0.5 # The time limit for worker processes

  def initialize
    @queue = SizedQueue.new(LIMIT_WAITING)
    @eoq_reached = false

    print Time.now.strftime('%H:%M:%S.%6N') + "] > Using #{N_THREADS} threads\n"
  end

  # Main method -------------------------------------------

  def run
    t1 = producer

    t2 = Array.new(N_THREADS) { |n| worker(n) }

    t1.join
    t2.each(&:join)
    puts '> Process complete'.green
  end

  # Queue methods -----------------------------------------

  def producer
    print Time.now.strftime('%H:%M:%S.%6N') + "] ! PRODUCER STARTING\n"
    Thread.new do
      TOTAL_ITEMS.times do |i|
        payload = (rand * 10).round(2) # Payload is an integer, increases by 1 every iteration

	print Time.now.strftime('%H:%M:%S.%6N') + "] > pushing " + " ##{i}: " + payload.to_s.underline + "\n"
        @queue.push payload
        # sleep rand
      end
      @queue.push EOQ # Add the end-of-queue object when we're finished
      print Time.now.strftime('%H:%M:%S.%6N') + "] \n! PRODUCER EXITING, pushed #{EOQ}\n\n"
    end
  end

  # Consume from queue and thread
  def worker(id)
    print Time.now.strftime('%H:%M:%S.%6N') + "] \n! WORKER #{id} STARTING\n\n"
    Thread.new do
      worker = Task.new(id)
      loop do
        payload = @queue.pop
        break if queue_empty?(payload, id)

        send_to_worker(worker, payload)
        sleep rand * 2 # Rate limit consumption per worker
      end
      print Time.now.strftime('%H:%M:%S.%6N') + "] >>WORKER #{id} EXITING\n\n"
    end
  end

  def queue_empty?(payload, worker_id)
    if payload == EOQ
      @queue.push EOQ
      print Time.now.strftime('%H:%M:%S.%6N') + "] ! worker #{worker_id} reached EOQ\n"
      return true
    end
    false
  end

  def send_to_worker(worker, payload, retries = 3)
    payload = (payload - 2).round(2) if retries != 3
    payload = 1 if retries == 1

    Timeout.timeout(TIMEOUT) { worker.work(payload) }
  rescue Timeout::Error
    print Time.now.strftime('%H:%M:%S.%6N') + '] !!'.red + "worker #{worker.id} " + ' ' * 11 * 3 + 'fail: '.red + payload.to_s +
          ", retries: #{retries}\n"
    retry if (retries -= 1) > 0
  end

  # Performs the task that all this queueing has been about.
  # Currently, it just sleeps for a random time and returns the milliseconds.
  class Task
    attr_reader :id
    def initialize(id)
      @id = id.to_i
      print Time.now.strftime('%H:%M:%S.%6N') + '] > initialized worker '.green + id.to_s + "\n"
    end

    def work(payload)
      print Time.now.strftime('%H:%M:%S.%6N') + "] - worker #{@id} " + ' ' * 11 + 'work: '.yellow + payload.to_s + "\n"

      sleep(payload / 10)

      print Time.now.strftime('%H:%M:%S.%6N') + '] >>'.green + "worker #{@id} " + ' ' * 11 * 2 + 'done: '.green +
            payload.to_s + "\n"
    end
  end
end

LifeKey.new.run if $PROGRAM_NAME == __FILE__
