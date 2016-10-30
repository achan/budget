FactoryGirl.define do
  factory :expense do
    name { Forgery("lorem_ipsum").title(random: true) }
    account { build(:account) }
    amount_in_cents { Forgery('basic').number * 1000 }
    frequency { %i(y m w b).sample }
  end
end
