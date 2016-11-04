require "json"

class Budget
  def initialize(accounts, incomes, expenses)
    @accounts = accounts
    @incomes = incomes
    @expenses = expenses
  end

  def balances
    @accounts.
      map { |a| { slug: a.slug, balance: yearly_income(a) - yearly_expense(a) } }.
      each_with_object({}) do |balance, acc|
        acc[balance[:slug]] = balance[:balance]
        acc
      end
  end

  def loans
    @expenses.
      select(&:paid_by_account).
      each_with_object({}) do |expense, acc|
        acc[expense.account.slug] ||= {}
        acc[expense.account.slug][expense.paid_by_account.slug] ||= 0 
        acc[expense.account.slug][expense.paid_by_account.slug] += calculate_yearly_amount(expense)

        acc
      end
  end

  def to_s
    "Yearly balances: #{balances}
Yearly loans: #{loans}"
  end

  private

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
