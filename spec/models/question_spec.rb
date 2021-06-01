RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should have_many(:answers).dependent(:destroy) }
    it { should belong_to(:author).class_name('User').required }
    it { should belong_to(:best_answer).class_name('Answer').optional }
    it { should have_many(:links).dependent(:destroy) }
    it { should have_one(:award).dependent(:destroy).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'others' do
    it { expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many) }
    it { should accept_nested_attributes_for :links }
    it { should accept_nested_attributes_for :award }
  end
end
