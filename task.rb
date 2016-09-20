#! /usr/bin/env ruby
$LOAD_PATH.unshift(__dir__)

require 'margin'

# Performs the task that all this queueing has been about.
# Currently, it just sleeps for a random time and returns the milliseconds.
class Task
  def initialize(id)
    @id = id.to_i
  end

  def work(obj, _queue_size)
    Timeout.timeout(5) do
      time = rand * 10
      # Margin.print_margin(:proc_start, obj, queue_size)
      sleep(time)
      # Margin.print_margin(:proc_fin, obj, queue_size)
      time
    end
  rescue Timeout::Error
    puts "* caught!! #{obj}".red
    # Margin.print_margin(:timeout, obj, queue_size)
  end
end
