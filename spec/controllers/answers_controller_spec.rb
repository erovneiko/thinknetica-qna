require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let(:answer) { create(:answer, question: question, author: user) }

  describe 'POST #create' do
    context 'Authorized user' do
      before { login(user) }

      context 'valid attributes' do
        it 'saves a new answer' do
          expect do
            post :create, params: {
              answer: attributes_for(:answer),
              question_id: question,
            }
          end.to change(question.answers, :count).by(1)
        end

        it 'redirects to question\'s show' do
          post :create, params: { question_id: question, answer: attributes_for(:answer) }
          expect(response).to redirect_to question
        end
      end

      context 'invalid attributes' do
        it 'does not save answer' do
          expect do
            post :create, params: {
              question_id: question,
              answer: attributes_for(:answer, :invalid)
            }
          end.to_not change(question.answers, :count)
        end

        it 're-renders question\' show' do
          post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }
          expect(response).to render_template 'questions/show'
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
        end.to_not change(question.answers, :count)
      end

      it 'redirects to login page' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'Authorized user' do
      context 'deletes his answer' do
        before { login(user) }

        it 'deletes the answer' do
          answer
          expect { delete :destroy, params: { id: answer } }.to change(question.answers, :count).by(-1)
        end

        it 'redirects to question' do
          delete :destroy, params: { id: answer }
          expect(response).to redirect_to question_path(question)
        end
      end

      context 'deletes another answer' do
        let(:another_user) { create(:user) }
        before { login(another_user) }

        it 'does not delete the answer' do
          answer
          expect { delete :destroy, params: { id: answer } }.to_not change(question.answers, :count)
        end

        it 'returns status forbidden' do
          delete :destroy, params: { id: answer }
          expect(response).to have_http_status(:forbidden)
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
end
