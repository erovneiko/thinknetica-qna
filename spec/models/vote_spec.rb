RSpec.describe Vote, type: :model do
  it { should belong_to(:user).required }
  it { should belong_to(:votable).required }

  describe 'logic' do
    let(:user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let(:vote) { question.votes.create(user: user) }

    it 'can vote up' do
      expect { vote.up }.to change { question.votes_sum }.by(1)
    end

    it 'can vote down' do
      expect { vote.down }.to change { question.votes_sum }.by(-1)
    end
  end
end
