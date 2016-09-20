#! /usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path('../', __dir__))

require 'margin'

# Prints single & combined examples of the margin characters
module MarginTest
  module_function

  def test
    test_chars
    test_combos
  end

  def test_chars
    Margin::CHAR.each do |key, char|
      printf "%-12s: %-2s\n", key, char
    end
  end

  def test_combos
    Margin::LINES.each do |key, line|
      printf "%-12s: %-20s\n", key, line
    end
  end
end

MarginTest.test if $PROGRAM_NAME == __FILE__
