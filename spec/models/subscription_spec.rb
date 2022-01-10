RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:user).required }
    it { should belong_to(:subscriptable).required }
  end
end
