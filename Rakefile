require "./lib/budget"
require "./lib/models/frequency"
require "./lib/models/account"
require "./lib/models/income"
require "./lib/models/expense"
require "./lib/services/data_importer_service"
require "./lib/services/tithe_expense_service"
require "json"

task :print_budget do
  json = JSON.parse(File.read("data.json"), symbolize_names: true)
  puts DataImporterService.new(json).build_budget.to_s
end
