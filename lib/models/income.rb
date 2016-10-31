class Income
  attr_accessor :name, :account, :amount_in_cents, :frequency, :tithable

  def tithable?
    tithable == true
  end

  def ==(other_income)
    %i(name account amount_in_cents frequency tithable).each do |attr|
      return false unless send(attr) == other_income.send(attr)
    end

    true
  end
end
