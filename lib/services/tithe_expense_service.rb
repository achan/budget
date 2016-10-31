class TitheExpenseService
  def initialize(tithe_account)
    @tithe_account = tithe_account
  end

  def process(expenses, incomes)
    expenses + [tithable_expense(incomes)].reject { |i| i.amount_in_cents == 0 }
  end

  private

  def tithable_expense(incomes)
    expense = Expense.new
    expense.name = "Tithe"
    expense.account = @tithe_account
    expense.amount_in_cents = monthy_tithe_in_cents(incomes)
    expense.frequency = Frequency::MONTHLY
    expense.paid_by_account = nil
    expense
  end

  def monthy_tithe_in_cents(incomes)
    total =
      incomes.
        select { |i| i.tithable? }.
        each_with_object({ total: 0 }) do |income, acc|
          acc[:total] += monthly_tithe_for_income(income)
        end

    total[:total]
  end

  def monthly_tithe_for_income(income)
    calculator[income.frequency].call(income.amount_in_cents)
  end

  def calculator
    {
      m: Proc.new { |income_in_cents| income_in_cents * 0.1 },
      b: Proc.new { |income_in_cents| income_in_cents * 26 / 12 * 0.1 },
      w: Proc.new { |income_in_cents| income_in_cents * 52 / 12 * 0.1 },
      y: Proc.new { |income_in_cents| income_in_cents / 12 * 0.1 }
    }
  end
end
