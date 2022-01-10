RSpec.describe SubscriptionsController, type: :controller do
  describe 'PUT #create' do
    describe 'authorized' do
      it 'creates subscription'
      it 'returns script'
    end

    describe 'not authorized' do
      it 'returns forbidden'
    end
  end

  describe 'DELETE #destroy' do
    describe 'authorized' do
      it 'deletes subscription'
      it 'returns script'
    end

    describe 'not authorized' do
      it 'returns forbidden'
    end
  end
end
