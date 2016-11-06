class CombinePaymentsService
  def process(payments)
    accounts_to_combine = accounts_with_multiple_transactions(payments)

    (unique_account_payments(payments, accounts_to_combine) +
      accounts_to_combine.map do |accounts|
        account_payments = payments_between_accounts(payments, *accounts)
        squash_payments(account_payments)
      end.compact).
      sort_by { |p| [p.from_account, -p.amount_in_cents] }
  end

  private

  def unique_account_payments(payments, accounts_to_combine)
    payments.reject do |p|
      accounts_to_combine.each_with_object({ reject: false }) do |accounts, should_reject|
        should_reject[:reject] || should_reject[:reject] = p.between_accounts?(*accounts)
      end[:reject]
    end
  end

  def paying_accounts(payments)
    payments.map(&:from_account).uniq
  end

  def transacting_accounts(payments)
    payments.map { |p| [p.from_account, p.to_account].sort }
  end

  def accounts_with_multiple_transactions(payments)
    all_transacting_accounts = transacting_accounts(payments)
    all_transacting_accounts.
      select { |accounts| all_transacting_accounts.count(accounts) > 1 }.
      uniq
  end

  def payments_between_accounts(payments, account1, account2)
    payments.select { |p| p.between_accounts?(account1, account2) }
  end

  def squash_payments(payments)
    from_account = payments.first.from_account
    to_account = payments.first.to_account
    payment =
      Payment.new(
        from_account: from_account,
        to_account: to_account,
        amount_in_cents: 0,
        frequency: Frequency::YEARLY
      )

    payments.each_with_object(payment) do |current_payment, acc|
      yearly_payment = current_payment.yearly
      if yearly_payment.from_account == from_account
        payment.amount_in_cents += yearly_payment.amount_in_cents
      else
        payment.amount_in_cents -= yearly_payment.amount_in_cents
      end
    end

    payment = payment.monthly

    return payment if payment.amount_in_cents > 0
    return if payment.amount_in_cents == 0

    Payment.new(
      from_account: to_account,
      to_account: from_account,
      amount_in_cents: -payment.amount_in_cents,
      frequency: Frequency::MONTHLY
    )
  end
end
