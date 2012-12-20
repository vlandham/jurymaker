#!/usr/bin/env ruby

require 'json'
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

id = report_data["custom_report"]["id"]

report_dir = File.join(output_dir, "jurydata_#{id}")

command = "git clone #{jurydata_url} #{report_dir}"
execute command

command = "cp #{report_request_filename} #{report_dir}/data/input.json"
execute command

case_filename = File.join(report_dir, "data", "case.html")
case_html = report_data["custom_report"]["description_html"]
File.open(case_filename, 'w') do |file|
  file.puts case_html
end

