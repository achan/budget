require "services/data_importer_service"
require "models/account"
require "models/income"
require "models/expense"
require "models/frequency"

describe DataImporterService do
  describe "#accounts" do
    let(:importer) { DataImporterService.new(json) }

    subject { importer.accounts }

    context "with multiple accounts" do
      let(:json) do
        {
          accounts: [
            { slug: "credit-card", name: "Credit Card" },
            { slug: "savings", name: "Savings" }
          ]
        }
      end

      let(:accounts) do
        [
          build(:account, slug: "credit-card", name: "Credit Card"),
          build(:account, slug: "savings", name: "Savings")
        ]
      end

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
          accounts: [
            { slug: "savings", name: "Savings" }
          ],
          incomes: [
            { name: "Rent", account: "savings", amount_in_cents: 95000, frequency: "m" },
            { name: "Salary", account: "savings", amount_in_cents: 70000, frequency: "b" }
          ]
        }
      end

      let(:savings_account) do
        build(:account, slug: "savings", name: "Savings")
      end

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
          accounts: [
            { slug: "savings", name: "Savings" },
            { slug: "credit-card", name: "Credit Card" }
          ],
          expenses: [
            { name: "Phone Bill", account: "savings", amount_in_cents: 95000, frequency: "m", paid_by_account: "credit-card" },
            { name: "Child Support", account: "savings", amount_in_cents: 70000, frequency: "b" }
          ]
        }
      end

      let(:savings_account) do
        build(:account, slug: "savings", name: "Savings")
      end

      let(:credit_card_account) do
        build(:account, slug: "credit-card", name: "Credit Card")
      end

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

    context "with no expenses" do
      subject { DataImporterService.new({}).expenses }
      it { is_expected.to eq [] }
    end
  end
end
