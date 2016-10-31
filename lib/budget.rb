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

  def yearly_income(account)
    calculate_total(@incomes, account)
  end

  def yearly_expense(account)
    calculate_total(@expenses, account)
  end

  def calculate_total(scheduled_transactions, account)
    total =
      scheduled_transactions.
        select { |s| s.account == account }.
        each_with_object({ total: 0 }) do |s, acc|
          acc[:total] += calculator[s.frequency].call(s.amount_in_cents)
        end

    total[:total]
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
