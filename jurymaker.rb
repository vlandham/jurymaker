#!/usr/bin/env ruby

require 'json'
report_request_filename = ARGV[0]

def execute command
  puts command
  system(command)
end

jurydata_url = "git@github.com:vlandham/jurydata_report.git"

report_data = JSON.parse(File.open(report_request_filename, 'r').read)

id = report_data["custom_report"]["id"]

report_dir = "jurydata_#{id}"

command = "git clone #{jurydata_url} #{report_dir}"
execute command

command = "cp #{report_request_filename} #{report_dir}/data/input.json"
execute command
