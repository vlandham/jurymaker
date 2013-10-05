#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'csv'

TURK_TEMPLATE = File.join(File.dirname(__FILE__), "assets", "turk_task_multi.html")


class TurkCSV
  def initialize reports_data
    @reports = reports_data
  end

  def write output_file

    headers = ["plaintiff", "defendant", "description", "id"]
    CSV.open(output_file, 'w') do |csv|
      csv << headers
      @reports.each do |report|
        csv << [report['custom_report']['plaintiff'], report['custom_report']['defendant'], report['custom_report']['description_html'], report['custom_report']['id']]
      end
    end
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
puts report_data.inspect

template = TurkCSV.new(report_data)

csv_output_filename = File.join(output_dir, "turk_input.csv")

template.write csv_output_filename

html_output_filename = File.join(output_dir, "turk_task.html")
system("cp #{TURK_TEMPLATE} #{html_output_filename}")


