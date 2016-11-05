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
end
