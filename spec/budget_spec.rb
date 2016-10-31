require "budget"
require "models/account"
require "models/income"
require "models/expense"
require "models/frequency"
require "services/data_importer_service"

describe Budget do
  describe "#balances" do
    let(:joint_account) { build(:account, name: "Joint", slug: "joint") }
    let(:savings_account) { build(:account, name: "Savings", slug: "savings") }

    let(:accounts) { [joint_account, savings_account] }

    let(:incomes) do
      [
        build(:income, name: "Salary", account: joint_account, amount_in_cents: 90000, frequency: Frequency::BI_WEEKLY),
        build(:income, name: "Moonlight", account: joint_account, amount_in_cents: 10000, frequency: Frequency::MONTHLY),
        build(:income, name: "Rent", account: savings_account, amount_in_cents: 100000, frequency: Frequency::MONTHLY)
      ]
    end

    let(:expenses) do
      [
        build(:expense, name: "Laval Mortgage", account: joint_account, amount_in_cents: 50000, frequency: Frequency::MONTHLY),
        build(:expense, name: "South Shore Mortgage", account: savings_account, amount_in_cents: 25000, frequency: Frequency::BI_WEEKLY)
      ]
    end

    subject { Budget.new(accounts, incomes, expenses).balances }

    it "lists accounts and their balances" do
      expect(subject).to eq({
        "joint" => (90000 * 26) + (10000 * 12) - (50000 * 12),
        "savings" => (100000 * 12) - (25000 * 26),
      })
    end
  end
end
