class BalanceReconciliationService
  def process(balances)
    balances = ordered_balances(balances)
    largest_account = balances.shift
    create_payments(largest_account, balances.select { |b| b[1] != 0 })
  end


  private

  def create_payments(from_account, accounts_to_reconcile)
    amount_in_account = from_account[1]
    accounts_to_reconcile.map do |account|
      amount_to_pay = account[1].abs
      amount_in_account -= amount_to_pay
      raise "No more money" if amount_in_account < 0
      Payment.new(
        from_account: from_account[0],
        to_account: account[0],
        amount_in_cents: amount_to_pay / 26.0,
        frequency: Frequency::BI_WEEKLY
      )
    end
  end

  def ordered_balances(balances)
    balances.map { |k, v| [k, v] }.sort { |x, y| y[1] <=> x[1] }
  end
end
