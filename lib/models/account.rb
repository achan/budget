class Account
  attr_accessor :slug, :name

  def ==(other_account)
    self.slug == other_account.slug && self.name == other_account.name
  end
end
