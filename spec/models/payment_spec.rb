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
end
