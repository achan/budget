class Income
  attr_accessor :name, :account, :amount_in_cents, :frequency

  def ==(other_income)
    %i(name account amount_in_cents frequency).each do |attr|
      return false unless send(attr) == other_income.send(attr)
    end

    true
  end
end
