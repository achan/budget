class Expense
  attr_accessor :name, :account, :amount_in_cents, :frequency, :paid_by_account

  FREQUENCY_IN_WORDS = {
    b: "every two weeks",
    w: "every week",
    m: "every month",
    y: "every year"
  }

  def ==(other_income)
    %i(name account amount_in_cents frequency paid_by_account).each do |attr|
      return false unless send(attr) == other_income.send(attr)
    end

    true
  end

  def to_s
    paying_account = account
    paying_account = "#{paying_account} paid by #{paid_by_account.name}" if paid_by_account
    "[#{paying_account}] #{name} ($#{"%.2f" % (amount_in_cents / 100.0)}) #{FREQUENCY_IN_WORDS[frequency]}."
  end
end
