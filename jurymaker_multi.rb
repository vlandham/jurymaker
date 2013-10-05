#!/usr/bin/env ruby

require 'json'

TURK_SCRIPT = File.join(File.dirname(__FILE__), 'turk_task_multi.rb')

report_request_filename = ARGV[0]
output_dir = ARGV[1]

if !output_dir
  output_dir = File.dirname(report_request_filename)
end

def execute command
  puts command
  system(command)
end

jurydata_url = "git@github.com:vlandham/jurydata_report.git"

report_data = JSON.parse(File.open(report_request_filename, 'r').read)

id = report_data.collect {|r| r["custom_report"]["id"]}.join("_")

report_dir = File.join(output_dir, "jurydata_#{id}")

command = "git clone #{jurydata_url} #{report_dir}"
execute command


report_data.each do |report|

  id = report["custom_report"]["id"]

  input_filename = File.join(report_dir, 'data', "input_#{id}.json")

  File.open(input_filename, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(report.to_json))
  end

  case_filename = File.join(report_dir, "data", "case_#{id}.html")
  case_html = report["custom_report"]["description_html"]
  File.open(case_filename, 'w') do |file|
    file.puts case_html
  end
end

turk_task_output = File.join(report_dir, "data")
system("#{TURK_SCRIPT} #{report_request_filename} #{turk_task_output}")
