RSpec.describe Link, type: :model do
  it { should belong_to :linkable }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url }

  it { is_expected.to validate_url_of(:url) }

  describe 'gist?' do
    let(:user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let(:gist) { create(:link, linkable: question, name: 'gist', url: 'https://gist.github.com/erovneiko/dd9ff32bae31c8c91adaaed8c7b15cc7') }
    let(:google) { create(:link, linkable: question, name: 'google', url: 'https://google.com') }

    it 'returns true if gist' do
      expect(gist).to be_gist
    end

    it 'returns false if not gist' do
      expect(google).not_to be_gist
    end
  end
end
