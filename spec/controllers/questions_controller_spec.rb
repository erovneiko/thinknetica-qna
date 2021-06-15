RSpec.describe QuestionsController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, author: user1) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 3, author: user1) }

    before { get :index }

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    context 'authorized user' do
      before { login(user1) }
      before { get :show, params: { id: question } }

      it 'assigns the requested question to @question' do
        expect(assigns(:question)).to eq question
      end

      it 'assigns new answer for question' do
        expect(assigns(:answer)).to be_a_new(Answer)
      end

      it 'assigns new link for answer' do
        expect(assigns(:answer).links.first).to be_a_new(Link)
      end

      it 'renders show view' do
        expect(response).to render_template :show
      end
    end

    context 'unauthorized user' do
      before { get :show, params: { id: question } }

      it 'assigns the requested question to @question' do
        expect(assigns(:question)).to eq question
        expect(assigns(:answer)).to eq nil
      end

      it 'renders show view' do
        expect(response).to render_template :show
      end
    end
  end

  describe 'GET #new' do
    context 'authorized user' do
      before { login(user1) }
      before { get :new }

      it 'assigns a new Question to @question' do
        expect(assigns(:question)).to be_a_new(Question)
      end

      it 'creates new empty link for question' do
        expect(assigns(:question).links.first).to be_a_new(Link)
      end

      it 'creates new empty award for question' do
        expect(assigns(:question).award).to be_a_new(Award)
      end

      it 'renders new view' do
        expect(response).to render_template :new
      end
    end

    context 'unauthorized user' do
      it 'redirects to login page' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #create' do
    context 'authorized user' do
      before { login(user1) }

      context 'with valid attributes' do
        it 'saves a new question in the database' do
          expect do
            post :create, params: { question: attributes_for(:question) }
          end.to change(Question, :count).by(1)
        end

        it 'redirects to index page' do
          post :create, params: { question: attributes_for(:question) }
          expect(response).to redirect_to questions_path
        end
      end

      context 'with invalid attributes' do
        it 'does not save the question' do
          expect { post :create, params: { question: attributes_for(:question, :invalid) } }.to_not change(Question, :count)
        end

        it 're-renders new view' do
          post :create, params: { question: attributes_for(:question, :invalid) }
          expect(response).to render_template :new
        end
      end
    end

    context 'unauthorized user' do
      it 'does not save the question' do
        expect { post :create, params: { question: attributes_for(:question) } }.to_not change(Question, :count)
      end

      it 'redirects to login page' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PATCH #update' do
    context 'author' do
      before { login(user1) }

      context 'with valid attributes' do
        it 'changes question attributes' do
          patch :update, params: { id: question, question: { title: 'Updated title', body: 'Updated body' } }, format: :js
          question.reload
          expect(question.title).to eq 'Updated title'
          expect(question.body).to eq 'Updated body'
        end

        it 'renders update view' do
          patch :update, params: { id: question, question: attributes_for(:question) }, format: :js
          expect(response).to render_template :update
        end
      end

      context 'with invalid attributes' do
        it 'does not change question' do
          expect do
            patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js
          end.to_not change(question, :title)
        end

        it 'renders update view' do
          patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js
          expect(response).to render_template :update
        end
      end
    end

    context 'non-author' do
      before { login(user2) }
      before { patch :update, params: { id: question, question: { title: 'Updated title', body: 'Updated body' } } }

      it 'does not change question' do
        question.reload
        expect(question.title).to eq 'Question title'
        expect(question.body).to eq 'Question body'
      end

      it 'returns status forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'authorized user' do
      context 'author' do
        before { login(user1) }

        it 'deletes the question' do
          question
          expect { delete :destroy, params: { id: question }, format: :js }.to change(Question, :count).by(-1)
        end

        it 'renders ajax answer' do
          delete :destroy, params: { id: question }, format: :js
          expect(response).to render_template :update
        end
      end

      context 'not author' do
        let(:another_user) { create(:user) }
        before { login(another_user) }

        it 'does not delete the question' do
          question
          expect { delete :destroy, params: { id: question } }.not_to change(Question, :count)
        end

        it 'returns status forbidden' do
          delete :destroy, params: { id: question }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'unauthorized user' do
      it 'does not delete the question' do
        question
        expect { delete :destroy, params: { id: question } }.not_to change(Question, :count)
      end

      it 'redirects to login page' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'votes' do
    describe 'authorized user' do
      context 'PUT #vote_up' do
        before { login(user2) }

        it 'loads question' do
          put :vote_up, params: { id: question }, format: :js
          expect(assigns(:question)).to eq question
        end

        it 'changes the vote if voted down' do
          question.votes.create(user: user2, result: -1)
          expect { put :vote_up, params: { id: question }, format: :js }.to change { question.votes.sum(:result) }.by(2)
        end

        it 'creates new vote if not voted' do
          expect { put :vote_up, params: { id: question }, format: :js }.to change { question.votes.sum(:result) }.by(1)
        end

        it 'renders json with results' do
          put :vote_up, params: { id: question }, format: :js
          expect(response.content_type).to match 'json'
          expect(response.body).to eq '{"votes":1}'
        end
      end

      context 'PUT #vote_down' do
        before { login(user2) }

        it 'loads question' do
          put :vote_down, params: { id: question }, format: :js
          expect(assigns(:question)).to eq question
        end

        it 'changes the vote if voted up' do
          question.votes.create(user: user2, result: 1)
          expect { put :vote_down, params: { id: question }, format: :js }.to change { question.votes.sum(:result) }.by(-2)
        end

        it 'creates vote if not voted' do
          expect { put :vote_down, params: { id: question }, format: :js }.to change { question.votes.sum(:result) }.by(-1)
        end

        it 'renders json with results' do
          put :vote_down, params: { id: question }, format: :js
          expect(response.content_type).to match 'json'
          expect(response.body).to eq '{"votes":-1}'
        end
      end
    end

    context 'unauthorized user' do
      context 'PUT #vote_up' do
        it 'returns status unauthorized' do
          put :vote_up, params: { id: question }, format: :js
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'PUT #vote_down' do
        it 'returns status unauthorized' do
          put :vote_down, params: { id: question }, format: :js
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'author' do
      before { login(user1) }

      context 'PUT #vote_up' do
        it 'returns status forbidden' do
          put :vote_up, params: { id: question }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'PUT #vote_down' do
        it 'returns status forbidden' do
          put :vote_down, params: { id: question }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
