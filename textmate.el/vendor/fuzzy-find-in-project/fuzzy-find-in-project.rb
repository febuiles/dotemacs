#! /usr/bin/env ruby

# Author: Justin Weiss
# This is a simple binding to the fuzzy_file_finder gem. It really only makes
# sense in the context of the fuzzy-find-in-project.el Emacs plugin. It takes
# a query in stdin and returns a list of matching file names in stdout.
# Usage: ./fuzzy-find-in-project.rb <project-path>
# There is currently no error handling.

require 'rubygems'
require 'fuzzy_file_finder'

finder = FuzzyFileFinder.new(ARGV[0], 50000)
while string = $stdin.readline
  finder.find(string, 50).sort_by { |m| [-m[:score], m[:path]] }.each do |match|
     puts "%s" % match[:path]
  end
  puts "END"
end
