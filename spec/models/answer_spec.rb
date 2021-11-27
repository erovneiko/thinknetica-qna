RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to(:question) }
    it { should belong_to(:author).class_name('User').required }
    it { should have_many(:links).dependent(:destroy) }
    it { should have_many(:votes).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'business logic' do
    let(:user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let(:answer) { create(:answer, question: question, author: user) }

    it 'makes answer the best' do
      answer.is_the_best!
      expect(question.best_answer).to eq answer
    end

    it 'checks if answer the best' do
      answer.is_the_best!
      expect(answer.is_the_best?).to eq true
    end
  end

  describe 'others' do
    it 'have many attached files' do
      expect(Answer.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
    end

    it { should accept_nested_attributes_for :links }
  end
end
