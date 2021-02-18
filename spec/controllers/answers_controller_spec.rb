require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { create(:question) }
  let(:answer) { create(:answer, question: question) }

  describe 'GET #show' do
    it 'renders view' do
      get :show, params: { id: answer }
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    it 'renders view' do
      get :new, params: { question_id: question }
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'valid attributes' do
      it 'saves a new question' do
        expect {
          post :create, params: {
            question_id: question,
            answer: attributes_for(:answer)
          }
        }.to change(Answer, :count).by(1)
      end

      it 'redirects to show' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }
        expect(response).to redirect_to assigns(:answer)
      end
    end

    context 'invalid attributes' do
      it 'does not save' do
        expect {
          post :create, params: {
            question_id: question,
            answer: attributes_for(:answer, :invalid)
          }
        }.to_not change(Answer, :count)
      end

      it 're-renders new' do
        post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }
        expect(response).to render_template :new
      end
    end
  end
end
