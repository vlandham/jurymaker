#!/usr/bin/env ruby

require 'erb'
require 'json'

class TurkTask
  TURK_TEMPLATE = File.join(File.dirname(__FILE__), "assets", "turk_task.html.erb")
  def initialize report_data
    @report = report_data
  end

  def write
    template = ERB.new File.new(TURK_TEMPLATE).read, nil, "%<>"
    output = template.result(binding)
    output
  end
end

report_request_filename = ARGV[0]
output_dir = ARGV[1]


if !File.exists? report_request_filename
  puts "ERROR: need input report request"
  exit(1)
end

if !output_dir
  output_dir = File.dirname(report_request_filename)
end


report_data = JSON.parse(File.open(report_request_filename, 'r').read)

template = TurkTask.new(report_data)

output = template.write

output_filename = File.join(output_dir, "turk_task.html")

File.open(output_filename, 'w') do |file|
  file.puts output
end


