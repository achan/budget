require "./lib/budget"
require "./lib/models/frequency"
require "./lib/models/account"
require "./lib/models/income"
require "./lib/models/expense"
require "./lib/models/payment"
require "./lib/services/data_importer_service"
require "./lib/services/tithe_expense_service"
require "./lib/services/balance_reconciliation_service"
require "json"

task :print_budget do
  json = JSON.parse(File.read("data/budget.json"), symbolize_names: true)
  puts DataImporterService.new(json).build_budget.to_s
end
