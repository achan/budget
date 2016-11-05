class DataImporterService
  DEFAULTS = {
    accounts: [],
    incomes: [],
    expenses: []
  }

  def initialize(json)
    @raw_json = json
  end

  def accounts
    @accounts ||= json[:accounts]
  end

  def incomes
    @incomes ||= json[:incomes].map do |i|
      income = Income.new
      income.name = i[:name]
      income.amount_in_cents = i[:amount_in_cents]
      income.account = i[:account]
      income.frequency = i[:frequency].to_sym
      income.tithable = i[:tithable] == true
      income
    end
  end

  def expenses
    @expenses ||= begin
      expenses = json[:expenses].map do |e|
        expense = Expense.new
        expense.name = e[:name]
        expense.amount_in_cents = e[:amount_in_cents]
        expense.account = e[:account]
        expense.paid_by_account =e[:paid_by_account]
        expense.frequency = e[:frequency].to_sym
        expense
      end

      TitheExpenseService.new("Savings").process(expenses, incomes)
    end
  end

  def build_budget
    Budget.new(accounts, incomes, expenses)
  end

  private

  def json
    @json ||= DEFAULTS.merge(@raw_json)
  end
end
