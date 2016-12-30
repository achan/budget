describe Payment do
  describe "#to_s" do
    let(:payment) do
      Payment.new(
        from_account: "Spending Account",
        to_account: "Savings Account",
        amount_in_cents: 1000,
        frequency: frequency
      )
    end

    context "with a bi-weekly payment" do
      let(:frequency) { Frequency::BI_WEEKLY }
      subject { payment.to_s }

      it { is_expected.to eq "[Spending Account] Payment of $10.00 to Savings Account every two weeks." }
    end
  end

  describe "#monthly" do
    let(:payment) do
      Payment.new(
        from_account: "Savings",
        to_account: "Joint",
        amount_in_cents: 10,
        frequency: frequency
      )
    end

    context "with a bi-weekly payment" do
      let(:frequency) { Frequency::BI_WEEKLY }

      subject { payment.monthly }

      it "converts to monthly payment" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: (10 * 26 / 12.0).ceil,
          frequency: Frequency::MONTHLY
        )
      end
    end
  end

  describe "#semi_monthly" do
    let(:payment) do
      Payment.new(
        from_account: "Savings",
        to_account: "Joint",
        amount_in_cents: 10,
        frequency: frequency
      )
    end

    context "with a weekly payment" do
      let(:frequency) { Frequency::WEEKLY }

      subject { payment.semi_monthly }

      it "converts to semi-monthly payment (twice a month)" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: (10 * 52 / 24.0).ceil,
          frequency: Frequency::SEMI_MONTHLY
        )
      end
    end
  end

  describe "#bi_weekly" do
    let(:payment) do
      Payment.new(
        from_account: "Savings",
        to_account: "Joint",
        amount_in_cents: 10,
        frequency: frequency
      )
    end

    context "with a weekly payment" do
      let(:frequency) { Frequency::WEEKLY }

      subject { payment.bi_weekly }

      it "converts to bi-weekly payment" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: (10 * 52 / 26.0).ceil,
          frequency: Frequency::BI_WEEKLY
        )
      end
    end
  end

  describe "#weekly" do
    let(:payment) do
      Payment.new(
        from_account: "Savings",
        to_account: "Joint",
        amount_in_cents: 10,
        frequency: frequency
      )
    end

    context "with a monthly payment" do
      let(:frequency) { Frequency::MONTHLY }

      subject { payment.weekly }

      it "converts to bi-weekly payment" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: (10 * 12 / 52.0).ceil,
          frequency: Frequency::WEEKLY
        )
      end
    end
  end

  describe "#yearly" do
    let(:payment) do
      Payment.new(
        from_account: "Savings",
        to_account: "Joint",
        amount_in_cents: 10,
        frequency: frequency
      )
    end

    context "with a monthly payment" do
      let(:frequency) { Frequency::MONTHLY }

      subject { payment.yearly }

      it "converts to yearly payment" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: 120,
          frequency: Frequency::YEARLY
        )
      end
    end

    context "with a weekly payment" do
      let(:frequency) { Frequency::WEEKLY }

      subject { payment.yearly }

      it "converts to yearly payment" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: 520,
          frequency: Frequency::YEARLY
        )
      end
    end

    context "with a bi-weekly payment" do
      let(:frequency) { Frequency::BI_WEEKLY }

      subject { payment.yearly }

      it "converts to yearly payment" do
        expect(subject).to eq Payment.new(
          from_account: "Savings",
          to_account: "Joint",
          amount_in_cents: 260,
          frequency: Frequency::YEARLY
        )
      end
    end

    context "with a yearly payment" do
      let(:frequency) { Frequency::YEARLY }

      subject { payment.yearly }

      it { is_expected.to eq payment }
    end
  end
end
