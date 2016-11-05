describe BalanceReconciliationService do
  describe "#process" do
    context "when one account has enough to pay off the rest" do
      let(:balances) do
        {
          "Condo" => -200000,
          "Credit Card" => 0,
          "Joint" => 4220388,
          "Savings" => -3057464
        }
      end

      subject { BalanceReconciliationService.new.process(balances) }

      it "finds the account with the most money and pays off the other accounts" do
        expect(subject).to eq [
          Payment.new(from_account: "Joint", to_account: "Condo", amount_in_cents: 200000 / 26.0, frequency: Frequency::BI_WEEKLY),
          Payment.new(from_account: "Joint", to_account: "Savings", amount_in_cents: 3057464 / 26.0, frequency: Frequency::BI_WEEKLY)
        ]
      end
    end
  end
end
