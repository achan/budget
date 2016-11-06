describe CombinePaymentsService do
  describe "#process" do
    context "when there are no payments to combine" do
      let(:payments) do
        [
          Payment.new(from_account: "Savings", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Secret Account", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY)
        ]
      end

      subject { CombinePaymentsService.new.process(payments) }

      it "leaves payments alone" do
        expect(subject).to eq payments
      end
    end

    context "when there are multiple payments to squash" do
      let(:payments) do
        [
          Payment.new(from_account: "Savings", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 20000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 3000, frequency: Frequency::YEARLY),
          Payment.new(from_account: "Secret Account", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Secret Account", amount_in_cents: 20000, frequency: Frequency::MONTHLY)
        ]
      end

      subject { CombinePaymentsService.new.process(payments) }

      it "squashes the payments into one monthly payment" do
        expect(subject).to eq [
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 10250, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Secret Account", amount_in_cents: 10000, frequency: Frequency::MONTHLY)
        ]
      end
    end

    context "when there are multiple payments between two accounts" do
      let(:payments) do
        [
          Payment.new(from_account: "Savings", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 20000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 3000, frequency: Frequency::YEARLY),
        ]
      end

      subject { CombinePaymentsService.new.process(payments) }

      it "squashes the payments into one monthly payment" do
        expect(subject).to eq [
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 10250, frequency: Frequency::MONTHLY)
        ]
      end
    end

    context "when the total is negative" do
      let(:payments) do
        [
          Payment.new(from_account: "Savings", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 300000, frequency: Frequency::YEARLY)
        ]
      end

      subject { CombinePaymentsService.new.process(payments) }

      it "reverses the payment" do
        expect(subject).to eq [
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 15000, frequency: Frequency::MONTHLY)
        ]
      end
    end

    context "when payments end up equal ($0)" do
      let(:payments) do
        [
          Payment.new(from_account: "Savings", to_account: "Joint", amount_in_cents: 10000, frequency: Frequency::MONTHLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 10000, frequency: Frequency::MONTHLY)
        ]
      end

      subject { CombinePaymentsService.new.process(payments) }

      it "reverses the payment" do
        expect(subject).to eq []
      end
    end
  end
end
