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
        expect(assigns(:answer)).to be_a_new(Answer)
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

  describe 'DELETE #delete_file' do
    before do
      question.files.attach fixture_file_upload("#{Rails.root}/spec/rails_helper.rb")
    end

    context 'authorized user' do
      context 'author' do
        before { login(user1) }

        it 'deletes file' do
          expect do
            delete :delete_file, params: { id: question.files.first.id }, format: :js
          end.to change(question.files, :count).by(-1)
        end

        it 'assigns deleted file to attribute @file' do
          file = question.files.first
          delete :delete_file, params: { id: question.files.first.id }, format: :js
          expect(assigns(:file)).to eq file
        end

        it 'renders ajax answer' do
          delete :delete_file, params: { id: question.files.first.id }, format: :js
          expect(response).to render_template :delete_file
        end
      end

      context 'not author' do
        let(:another_user) { create(:user) }
        before { login(another_user) }

        it 'cannot delete file' do
          expect do
            delete :delete_file, params: { id: question.files.first.id }, format: :js
          end.not_to change(question.files, :count)
        end

        it 'returns status forbidden' do
          delete :delete_file, params: { id: question.files.first.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'unauthorized user' do
      it 'cannot delete file' do
        expect do
          delete :delete_file, params: { id: question.files.first.id }, format: :js
        end.not_to change(question.files, :count)
      end

      it 'returns status unauthorized' do
        delete :delete_file, params: { id: question.files.first.id }, format: :js
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
