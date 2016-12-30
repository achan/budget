require "services/tithe_expense_service"
require "models/frequency"
require "models/income"
require "models/expense"

describe TitheExpenseService do
  describe "#process" do
    context "with no tithable income" do
      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income,
                name: "Salary",
                amount_in_cents: 60000,
                frequency: Frequency::MONTHLY,
                account: savings_account)
        ]
      end

      subject { TitheExpenseService.new(savings_account).process([], incomes) }

      it "appends a monthly tithe" do
        expect(subject).to eq []
      end
    end

    context "with a monthly tithable income" do
      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income,
                name: "Salary",
                amount_in_cents: 60000,
                frequency: Frequency::MONTHLY,
                tithable: true,
                account: savings_account)
        ]
      end

      let(:tithe_expense) do
        build(:expense,
              name: "Tithe",
              amount_in_cents: 6000,
              frequency: Frequency::MONTHLY,
              account: savings_account)
      end

      subject { TitheExpenseService.new(savings_account).process([], incomes) }

      it "appends a monthly tithe" do
        expect(subject).to eq [tithe_expense]
      end
    end

    context "with a semi monthly tithable income" do
      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income,
                name: "Salary",
                amount_in_cents: 60000,
                frequency: Frequency::SEMI_MONTHLY,
                tithable: true,
                account: savings_account)
        ]
      end

      let(:tithe_expense) do
        build(:expense,
              name: "Tithe",
              amount_in_cents: 12000,
              frequency: Frequency::MONTHLY,
              account: savings_account)
      end

      subject { TitheExpenseService.new(savings_account).process([], incomes) }

      it "appends a monthly tithe" do
        expect(subject).to eq [tithe_expense]
      end
    end

    context "with a bi-weekly tithable income" do
      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income,
                name: "Salary",
                amount_in_cents: 60000,
                frequency: Frequency::BI_WEEKLY,
                tithable: true,
                account: savings_account)
        ]
      end

      let(:tithe_expense) do
        build(:expense,
              name: "Tithe",
              amount_in_cents: 60000 * 26 / 12 * 0.1,
              frequency: Frequency::MONTHLY,
              account: savings_account)
      end

      subject { TitheExpenseService.new(savings_account).process([], incomes) }

      it "appends a monthly tithe" do
        expect(subject).to eq [tithe_expense]
      end
    end

    context "with a weekly tithable income" do
      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income,
                name: "Salary",
                amount_in_cents: 60000,
                frequency: Frequency::WEEKLY,
                tithable: true,
                account: savings_account)
        ]
      end

      let(:tithe_expense) do
        build(:expense,
              name: "Tithe",
              amount_in_cents: 60000 * 52 / 12 * 0.1,
              frequency: Frequency::MONTHLY,
              account: savings_account)
      end

      subject { TitheExpenseService.new(savings_account).process([], incomes) }

      it "appends a monthly tithe" do
        expect(subject).to eq [tithe_expense]
      end
    end

    context "with a yearly tithable income" do
      let(:savings_account) { "Savings" }

      let(:incomes) do
        [
          build(:income,
                name: "Salary",
                amount_in_cents: 60000,
                frequency: Frequency::YEARLY,
                tithable: true,
                account: savings_account)
        ]
      end

      let(:tithe_expense) do
        build(:expense,
              name: "Tithe",
              amount_in_cents: 60000 / 12 * 0.1,
              frequency: Frequency::MONTHLY,
              account: savings_account)
      end

      subject { TitheExpenseService.new(savings_account).process([], incomes) }

      it "appends a monthly tithe" do
        expect(subject).to eq [tithe_expense]
      end
    end
  end
end
