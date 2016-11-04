FactoryGirl.define do
  factory :payment do
    account { build(:account) }
    amount_in_cents { Forgery('basic').number * 1000 }
    frequency { %i(y m w b).sample }
  end
end
