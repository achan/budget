class Expense
  attr_accessor :name, :account, :amount_in_cents, :frequency, :paid_by_account

  def ==(other_income)
    %i(name account amount_in_cents frequency paid_by_account).each do |attr|
      return false unless send(attr) == other_income.send(attr)
    end

    true
  end
end
