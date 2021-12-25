require_relative 'concerns/voted'

RSpec.describe AnswersController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, author: user1) }
  let(:answer) { create(:answer, question: question, author: user1) }

  describe 'POST #create' do
    context 'authorized user' do
      before { login(user1) }

      context 'valid attributes' do
        it 'saves a new answer' do
          expect do
            post :create, params: {
              answer: attributes_for(:answer),
              question_id: question
            }, format: :js
          end.to change(question.answers, :count).by(1)
        end

        it 'renders ajax answer' do
          post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
          expect(response).to render_template :create
        end

        context 'notification' do
          before { question.subscribers << user2 }

          it 'sends notification to subscribers' do
            expect(NotificationsMailer).to receive(:new_answer).and_call_original
            post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
          end
        end
      end

      context 'invalid attributes' do
        it 'does not save answer' do
          expect do
            post :create, params: {
              question_id: question,
              answer: attributes_for(:answer, :invalid)
            }, format: :js
          end.to_not change(Answer, :count)
        end

        it 'renders ajax answer' do
          post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }, format: :js
          expect(response).to render_template :create
        end
      end
    end

    context 'Unauthorized user' do
      it 'does not save answer' do
        expect do
          post :create, params: {
            question_id: question,
            answer: attributes_for(:answer)
          }
        end.to_not change(Answer, :count)
      end

      it 'redirects to login page' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PATCH #update' do
    context 'author' do
      before { login(user1) }

      context 'with valid attributes' do
        it 'changes answer attributes' do
          patch :update, params: { id: answer, answer: { body: 'Updated body' } }, format: :js
          answer.reload
          expect(answer.body).to eq 'Updated body'
        end

        it 'renders update view' do
          patch :update, params: { id: answer, answer: { body: 'Updated body' } }, format: :js
          expect(response).to render_template :update
        end
      end

      context 'with invalid attributes' do
        it 'does not change answer attributes' do
          expect do
            patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
          end.to_not change(answer, :body)
        end

        it 'renders update view' do
          patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
          expect(response).to render_template :update
        end
      end
    end

    context 'non-author' do
      before { login(user2) }
      before { patch :update, params: { id: answer, answer: { body: 'Updated body' } }, format: :js }

      it 'does not change answer' do
        answer.reload
        expect(answer.body).to eq 'Answer body'
      end

      it 'returns status forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'Authorized user' do
      context 'Author' do
        before { login(user1) }

        it 'deletes the answer' do
          answer
          expect { delete :destroy, params: { id: answer }, format: :js }.to change(question.answers, :count).by(-1)
        end

        it 'renders ajax answer' do
          delete :destroy, params: { id: answer }, format: :js
          expect(response).to render_template :update
        end
      end

      context 'Not author' do
        before { login(user2) }

        it 'does not delete the answer' do
          answer
          expect { delete :destroy, params: { id: answer } }.to_not change(question.answers, :count)
        end

        it 'returns authorization error' do
          delete :destroy, params: { id: answer }
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        end
      end
    end

    context 'Unauthorized user' do
      it 'does not delete the answer' do
        answer
        expect { delete :destroy, params: { id: answer } }.to_not change(question.answers, :count)
      end

      it 'redirects to login page' do
        delete :destroy, params: { id: answer }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PUT #best' do
    context 'authorized user' do
      context 'author of the question' do
        before { login(user1) }
        before { post :best, params: { id: answer }, format: :js }

        it 'makes answer the best' do
          question.reload
          expect(question.best_answer).to eq answer
        end

        it 'assigns current question to @question' do
          expect(assigns(:question)).to eq question
        end

        it 'renders ajax answer' do
          expect(response).to render_template :update
        end
      end

      context 'not author' do
        before { login(user2) }
        before { put :best, params: { id: answer }, format: :js }

        it 'does not make answer the best' do
          question.reload
          expect(question.best_answer).to eq nil
        end

        it 'returns status forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'not authorized user' do
      before { post :best, params: { id: answer } }

      it 'does not make answer the best' do
        question.reload
        expect(question.best_answer).to eq nil
      end

      it 'redirects to login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'Voted' do
    let(:votable) { answer }
    it_behaves_like 'Voted'
  end
end
