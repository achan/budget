require "services/data_importer_service"
require "models/income"
require "models/expense"
require "models/frequency"
require "services/tithe_expense_service"

describe DataImporterService do
  describe "#accounts" do
    let(:importer) { DataImporterService.new(json) }

    subject { importer.accounts }

    context "with multiple accounts" do
      let(:json) { { accounts: ["Credit Card", "Savings"] } }
      let(:accounts) { ["Credit Card", "Savings"] }

      subject { DataImporterService.new(json).accounts }

      it "imports accounts from json" do
        expect(subject).to eq accounts
      end
    end

    context "with no accounts" do
      subject { DataImporterService.new({}).accounts }
      it { is_expected.to eq [] }
    end
  end

  describe "#incomes" do
    context "with multiple incomes" do
      let(:json) do
        {
          accounts: ["Savings"],
          incomes: [
            { name: "Rent", account: "Savings", amount_in_cents: 95000, frequency: "m" },
            { name: "Salary", account: "Savings", amount_in_cents: 70000, frequency: "b" }
          ]
        }
      end

      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income, name: "Rent", amount_in_cents: 95000, frequency: Frequency::MONTHLY, account: savings_account),
          build(:income, name: "Salary", amount_in_cents: 70000, frequency: Frequency::BI_WEEKLY, account: savings_account)
        ]
      end

      subject { DataImporterService.new(json).incomes }

      it "imports incomes from json" do
        expect(subject).to eq incomes
      end
    end

    context "with no incomes" do
      subject { DataImporterService.new({}).incomes }
      it { is_expected.to eq [] }
    end
  end

  describe "#expenses" do
    context "with multiple expenses" do
      let(:json) do
        {
          accounts: [ "Savings", "Credit Card" ],
          expenses: [
            { name: "Phone Bill", account: "Savings", amount_in_cents: 95000, frequency: "m", paid_by_account: "Credit Card" },
            { name: "Child Support", account: "Savings", amount_in_cents: 70000, frequency: "b" }
          ]
        }
      end

      let(:savings_account) { "Savings" }

      let(:credit_card_account) { "Credit Card" }

      let(:expenses) do
        [
          build(:expense, name: "Phone Bill", amount_in_cents: 95000, frequency: Frequency::MONTHLY, account: savings_account, paid_by_account: credit_card_account),
          build(:expense, name: "Child Support", amount_in_cents: 70000, frequency: Frequency::BI_WEEKLY, account: savings_account)
        ]
      end

      subject { DataImporterService.new(json).expenses }

      it "imports expenses from json" do
        expect(subject).to eq expenses
      end
    end

    context "when there are tithable incomes" do
      let(:json) do
        {
          accounts: ["Savings"],
          incomes: [
            { name: "Rent", account: "Savings", amount_in_cents: 95000, frequency: "m" },
            { name: "Salary", account: "Savings", amount_in_cents: 70000, frequency: "b", tithable: true }
          ],
          expenses: [
            { name: "Child Support", account: "Savings", amount_in_cents: 70000, frequency: "b" }
          ]
        }
      end

      let(:incomes) do
        [
          build(:income, name: "Rent", amount_in_cents: 95000, frequency: Frequency::MONTHLY, account: savings_account),
          build(:income, name: "Salary", amount_in_cents: 70000, frequency: Frequency::BI_WEEKLY, account: savings_account, tithable: true)
        ]
      end

      let(:savings_account) { "Savings" }

      let(:credit_card_account) { "Credit Card" }

      let(:expenses) do
        [
          build(:expense, name: "Child Support", amount_in_cents: 70000, frequency: Frequency::BI_WEEKLY, account: savings_account),
        ]
      end

      let(:tithe_expense) do
        build(:expense, name: "Tithe", amount_in_cents: 70000 * 26 / 12 * 0.1, frequency: Frequency::MONTHLY, account: savings_account)
      end

      subject { DataImporterService.new(json).expenses }

      it "adds an expense for 10% of all tithable incomes" do
        expect(subject).to eq(expenses + [tithe_expense])
      end
    end

    context "with no expenses" do
      subject { DataImporterService.new({}).expenses }
      it { is_expected.to eq [] }
    end
  end
end
