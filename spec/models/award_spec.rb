require 'rails_helper'

RSpec.describe Award, type: :model do
  it { should belong_to(:question).required }
  it { should have_one_attached(:image) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:image) }
end
