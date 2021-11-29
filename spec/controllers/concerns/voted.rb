shared_examples 'Voted' do
  describe 'authorized user' do
    context 'PUT #vote_up' do
      before { login(user2) }

      it 'loads votable' do
        put :vote_up, params: { id: votable }, format: :js
        expect(assigns(:votable)).to eq votable
      end

      it 'changes the vote if voted down' do
        votable.votes.create(user: user2, result: -1)
        expect { put :vote_up, params: { id: votable }, format: :js }.to change { votable.votes_sum }.by(2)
      end

      it 'creates new vote if not voted' do
        expect { put :vote_up, params: { id: votable }, format: :js }.to change { votable.votes_sum }.by(1)
      end

      it 'renders json with results' do
        put :vote_up, params: { id: votable }, format: :js
        expect(response.content_type).to match 'json'
        expect(response.body).to eq '{"votes":1}'
      end
    end

    context 'PUT #vote_down' do
      before { login(user2) }

      it 'loads votable' do
        put :vote_down, params: { id: votable }, format: :js
        expect(assigns(:votable)).to eq votable
      end

      it 'changes the vote if voted up' do
        votable.votes.create(user: user2, result: 1)
        expect { put :vote_down, params: { id: votable }, format: :js }.to change { votable.votes_sum }.by(-2)
      end

      it 'creates vote if not voted' do
        expect { put :vote_down, params: { id: votable }, format: :js }.to change { votable.votes_sum }.by(-1)
      end

      it 'renders json with results' do
        put :vote_down, params: { id: votable }, format: :js
        expect(response.content_type).to match 'json'
        expect(response.body).to eq '{"votes":-1}'
      end
    end
  end

  context 'unauthorized user' do
    context 'PUT #vote_up' do
      it 'returns status unauthorized' do
        put :vote_up, params: { id: votable }, format: :js
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'PUT #vote_down' do
      it 'returns status unauthorized' do
        put :vote_down, params: { id: votable }, format: :js
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'author' do
    before { login(user1) }

    context 'PUT #vote_up' do
      it 'returns authorization error' do
        put :vote_up, params: { id: votable }, format: :js
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    context 'PUT #vote_down' do
      it 'returns authorization error' do
        put :vote_down, params: { id: votable }, format: :js
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end
  end
end
