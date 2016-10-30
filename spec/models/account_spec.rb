require "models/account"

describe Account do
  let(:account) { build(:account) }
  
  it "has a valid factory" do
    expect(build(:account)).not_to be_nil
  end

  describe "#==" do
    subject { build(:account) }

    it { is_expected.to eq build(:account, name: subject.name, slug: subject.slug) }

    context "when slug is different" do
      it { is_expected.not_to eq build(:account, name: subject.name) }
    end

    context "when name is different" do
      it { is_expected.not_to eq build(:account, slug: subject.slug) }
    end
  end
end
