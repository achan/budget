class Budget
  def initialize(accounts, incomes, expenses)
    @accounts = accounts
    @incomes = incomes
    @expenses = expenses
  end

  def balances
    @accounts.
      map { |a| { account: a, balance: yearly_income(a) - yearly_expense(a) } }.
      each_with_object({}) do |balance, acc|
        acc[balance[:account]] = balance[:balance]
        acc
      end
  end

  def loan_paypack_payments
    @expenses.
      select(&:paid_by_account).
      each_with_object({}) { |expense, acc| build_yearly_loan(expense, acc) }.
      map { |account, yearly_loan| build_payments(account, yearly_loan) }.
      flatten.
      sort_by { |payment| [payment.from_account, payment.amount_in_cents] }
  end

  def to_s
    "Yearly balances:
#{balances}

Balance Reconciliation:
#{BalanceReconciliationService.new.process(balances).map(&:to_s).join("\n")}

Loan Payback:
#{CombinePaymentsService.new.process(loan_paypack_payments).map(&:to_s).join("\n")}

Yearly savings:
#{display_amount(balances.values.inject(0, :+))}

Monthly savings:
#{display_amount(balances.values.inject(0, :+) / 12)}

Bi-Weekly savings:
#{display_amount(balances.values.inject(0, :+) / 26)}"
  end

  private

  def display_amount(cents)
    "$%.2f" % (cents / 100.0)
  end

  def build_yearly_loan(expense, acc)
    acc[expense.account] ||= {}
    acc[expense.account][expense.paid_by_account] ||= 0 
    acc[expense.account][expense.paid_by_account] += calculate_yearly_amount(expense)

    acc
  end

  def build_payments(account, yearly_loans)
    yearly_loans.map do |loan_account, amount|
      Payment.new(
        from_account: account,
        to_account: loan_account,
        amount_in_cents: amount / 12.0,
        frequency: Frequency::MONTHLY
      )
    end
  end

  def yearly_income(account)
    calculate_total_for_account(account, @incomes)
  end

  def yearly_expense(account)
    calculate_total_for_account(account, @expenses)
  end

  def calculate_total_for_account(account, scheduled_transactions)
    calculate_total(scheduled_transactions.select { |st| st.account == account })
  end

  def calculate_total(scheduled_transactions)
    total =
      scheduled_transactions.
        each_with_object({ total: 0 }) do |st, acc|
          acc[:total] += calculator[st.frequency].call(st.amount_in_cents)
        end

    total[:total]
  end

  def calculate_yearly_amount(scheduled_transaction)
    calculator[scheduled_transaction.frequency].
      call(scheduled_transaction.amount_in_cents)
  end

  def calculator
    {
      m: Proc.new { |cents| cents * 12 },
      b: Proc.new { |cents| cents * 26 },
      w: Proc.new { |cents| cents * 52 },
      y: Proc.new { |cents| cents }
    }
  end
end
