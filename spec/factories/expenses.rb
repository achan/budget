FactoryGirl.define do
  factory :expense do
    name { Forgery("lorem_ipsum").title(random: true) }
    account { Forgery("name").company_name }
    amount_in_cents { Forgery('basic').number * 1000 }
    frequency { %i(y m w b).sample }
    paid_by_account nil
  end
end
