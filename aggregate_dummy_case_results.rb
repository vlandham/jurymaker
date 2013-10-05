#!/usr/bin/env ruby

require 'csv'

starting_dir = ARGV[0]
output_filename = starting_dir + "/all_dummy_results.csv"

results_files = Dir.glob(File.join(starting_dir, "/**/data/results.csv"))

puts "#{results_files.size} files found"

def get_amount(amount_string)
  amount_string = amount_string.gsub("$","").gsub(",","")
  amount_string.to_f
end

def extract_details data_filename
  results = []
  CSV.foreach(data_filename, :headers => true) do |row|
    if row.headers.include?('Input.id') and row.headers.include?('Answer.zipcode') and row.headers.include?('Answer.test_amount')
      results.push({"id" => row['Input.id'], 'date' => row['AcceptTime'], 'amount' => get_amount(row['Answer.test_amount']), 'zip' => row['Answer.zipcode']})
    end
  end
  results
end
all = []
results_files.each do |results_file|
  begin
  all.concat(extract_details(results_file))
  rescue
    puts "problem with #{results_file}"
  end
end

CSV.open(output_filename, 'wb') do |csv|
  csv << ['id', 'date', 'amount', 'zip']
  all.each do |result|
    csv << [result['id'], result['date'], result['amount'], result['zip']]
  end
end
