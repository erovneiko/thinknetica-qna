require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should belong_to(:user).required }
  it { should belong_to(:votable).required }
end
