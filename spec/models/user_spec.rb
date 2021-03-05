require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:answers).with_foreign_key('author_id').dependent(:destroy) }
    it { should have_many(:questions).with_foreign_key('author_id').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
  end

  describe 'author_of?' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:question) { create(:question, author: user1) }

    it 'returns true' do
      expect(user1).to be_author_of(question)
    end

    it 'returns false' do
      expect(user2).not_to be_author_of(question)
    end
  end
end
