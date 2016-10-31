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
    @accounts ||= json[:accounts].map do |a|
      account = Account.new
      account.slug = a[:slug]
      account.name = a[:name]
      account
    end
  end

  def incomes
    @incomes ||= json[:incomes].map do |i|
      income = Income.new
      income.name = i[:name]
      income.amount_in_cents = i[:amount_in_cents]
      income.account = accounts_by_slug[i[:account]]
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
        expense.account = accounts_by_slug[e[:account]]
        expense.paid_by_account = accounts_by_slug[e[:paid_by_account]]
        expense.frequency = e[:frequency].to_sym
        expense
      end

      TitheExpenseService.
        new(accounts_by_slug["savings"]).
        process(expenses, incomes)
    end
  end

  private

  def json
    @json ||= DEFAULTS.merge(@raw_json)
  end

  def accounts_by_slug
    @accounts_by_slug ||= accounts.each_with_object({}) do |account, map|
      map[account.slug] = account
      map
    end
  end
end
