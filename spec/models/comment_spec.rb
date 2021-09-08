RSpec.describe Comment, type: :model do
  it { should belong_to(:commentable).required }
  it { should belong_to(:author).class_name('User').required }
  it { should validate_presence_of(:body) }
end
