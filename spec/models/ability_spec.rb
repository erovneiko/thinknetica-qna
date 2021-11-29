describe Ability, type: :model do
  subject(:ability) { Ability.new(user1) }

  describe 'for user' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:question1) { create(:question, author: user1) }
    let(:answer1) { create(:answer, question: question1, author: user1) }
    let(:comment1) { create(:comment, commentable: question1, author: user1) }
    let(:link1) { create(:link, linkable: question1, name: 'google', url: 'https://google.com') }
    let(:question2) { create(:question, author: user2) }
    let(:answer2) { create(:answer, question: question2, author: user2) }
    let(:comment2) { create(:comment, commentable: question2, author: user2) }
    let(:link2) { create(:link, linkable: question2, name: 'google', url: 'https://google.com') }

    it { should be_able_to :manage, :all }

    describe 'questions' do
      it { should be_able_to :update, question1 }
      it { should be_able_to :destroy, question1 }
      it { should_not be_able_to :update, question2 }
      it { should_not be_able_to :destroy, question2 }
    end

    describe 'answers' do
      it { should be_able_to :update, answer1 }
      it { should be_able_to :destroy, answer1 }
      it { should_not be_able_to :update, answer2 }
      it { should_not be_able_to :destroy, answer2 }
    end

    describe 'files' do
      before do
        question1.files.attach fixture_file_upload("#{Rails.root}/spec/rails_helper.rb")
        question2.files.attach fixture_file_upload("#{Rails.root}/spec/rails_helper.rb")
      end
      it { should be_able_to :update, question1.files.first }
      it { should be_able_to :destroy, question1.files.first }
      it { should_not be_able_to :update, question2.files.first }
      it { should_not be_able_to :destroy, question2.files.first }
    end

    describe 'links' do
      it { should be_able_to :update, link1 }
      it { should be_able_to :destroy, link1 }
      it { should_not be_able_to :update, link2 }
      it { should_not be_able_to :destroy, link2 }
    end

    describe 'best' do
      it { should be_able_to :best, answer1 }
      it { should_not be_able_to :best, answer2 }
    end

    describe 'comments' do
      it { should be_able_to :create, comment2 }
      it { should_not be_able_to :create, comment1 }
    end

    describe 'votes' do
      it { should be_able_to :vote, question2 }
      it { should_not be_able_to :vote, question1 }
    end
  end

  describe 'for guest' do
    let(:user1) { nil }
    let(:user2) { create(:user) }
    let(:question2) { create(:question, author: user2) }

    it { should be_able_to :read, :all }
    it { should_not be_able_to :read, Award.new(question: question2) }
    it { should_not be_able_to :vote, :all }
  end
end
