FactoryGirl.define do
  factory :account do
    slug { Forgery("lorem_ipsum").lorem_ipsum_words.sample(3).join("-") }
    name { Forgery("lorem_ipsum").title(random: true) }
  end
end
