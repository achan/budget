class Payment
  attr_accessor :from_account, :to_account, :amount_in_cents, :frequency

  FREQUENCY_IN_WORDS = {
    b: "every two weeks",
    w: "every week",
    m: "every month",
    y: "every year"
  }

  def initialize(from_account:, to_account:, amount_in_cents:, frequency:)
    @from_account = from_account
    @to_account = to_account
    @amount_in_cents = amount_in_cents
    @frequency = frequency
  end

  def between_accounts?(account1, account2)
    (from_account == account1 && to_account == account2) ||
      (from_account == account2 && to_account == account1)
  end

  def yearly
    Payment.new(
      from_account: from_account,
      to_account: to_account,
      amount_in_cents: yearly_calculator[frequency].call(amount_in_cents),
      frequency: Frequency::YEARLY
    )
  end

  def monthly
    convert_payment_to_frequency(Frequency::MONTHLY)
  end

  def bi_weekly
    convert_payment_to_frequency(Frequency::BI_WEEKLY)
  end

  def weekly
    convert_payment_to_frequency(Frequency::WEEKLY)
  end

  def to_s
    "[#{from_account}] Payment of $#{"%.2f" % (amount_in_cents / 100.0)} to #{to_account} #{FREQUENCY_IN_WORDS[frequency]}."
  end

  def ==(other_payment)
    return false unless other_payment

    %i(from_account to_account amount_in_cents frequency).each do |attr|
      return false unless send(attr) == other_payment.send(attr)
    end

    true
  end

  private

  def convert_payment_to_frequency(frequency)
    Payment.new(
      from_account: from_account,
      to_account: to_account,
      amount_in_cents: from_yearly_calculator[frequency].call(yearly.amount_in_cents),
      frequency: frequency
    )
  end

  def yearly_calculator
    {
      m: Proc.new { |cents| cents * 12 },
      b: Proc.new { |cents| cents * 26 },
      w: Proc.new { |cents| cents * 52 },
      y: Proc.new { |cents| cents }
    }
  end

  def from_yearly_calculator
    {
      m: Proc.new { |cents| cents / 12 },
      b: Proc.new { |cents| cents / 26 },
      w: Proc.new { |cents| cents / 52 },
      y: Proc.new { |cents| cents }
    }
  end
end
