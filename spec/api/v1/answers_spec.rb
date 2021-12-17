require 'rails_helper'

describe 'Questions API', type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let(:answer) { create(:answer, question: question, author: user) }
  let(:answer_response) { json['answer'] }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json',
                    'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions/:id' do
    let(:method) { :get }
    let(:api_path) { api_v1_answer_path(answer) }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let(:access_token) { create(:access_token) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token }
      end

      it 'returns status 200' do
        expect(response).to be_successful
      end

      it 'returns answers fields' do
        %w[id author_id body question_id created_at updated_at].each do |attr|
          expect(answer_response[attr]).to eq answer.send(attr).as_json
        end
      end
    end
  end

  describe 'POST /api/v1/questions' do
    let(:method) { :post }
    let(:api_path) { api_v1_question_answers_path(question) }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let(:access_token) { create(:access_token) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token,
                             answer: attributes_for(:answer) }
      end

      it 'returns status 201' do
        expect(response).to be_successful
      end

      it 'creates new answer' do
        expect(Answer.count).to be 1
      end

      it 'returns new question id' do
        expect(answer_response['id']).to be
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:method) { :patch }
    let(:api_path) { api_v1_answer_path(answer) }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      context 'author' do
        let(:access_token) { create(:access_token, resource_owner_id: user.id) }

        before do
          do_request method, api_path, headers: headers,
                     params: { access_token: access_token.token,
                               answer: { body: 'Updated' } }
        end

        it 'returns status 202' do
          expect(response).to be_successful
        end

        it 'updates question' do
          answer.reload
          expect(answer.body).to eq 'Updated'
        end

        it 'returns empty body' do
          expect(response.body).to be_empty
        end
      end

      context 'not author' do
        let(:access_token) { create(:access_token) }

        before do
          do_request method, api_path, headers: headers,
                     params: { access_token: access_token.token,
                               answer: { body: 'Updated' } }
        end

        it 'returns status 403' do
          expect(response).to have_http_status(:forbidden)
        end

        it "can't update question" do
          expect(answer.body).not_to be 'Updated'
        end

        it 'returns empty body' do
          expect(response.body).to be_empty
        end
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:method) { :delete }
    let(:api_path) { api_v1_answer_path(answer) }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      context 'author' do
        let(:access_token) { create(:access_token, resource_owner_id: user.id) }

        before do
          do_request method, api_path, headers: headers,
                     params: { access_token: access_token.token }
        end

        it 'returns status 200' do
          expect(response).to be_successful
        end

        it 'deletes question' do
          expect(Answer.count).to be_zero
        end

        it 'returns empty body' do
          expect(response.body).to be_empty
        end
      end

      context 'not author' do
        let(:access_token) { create(:access_token) }

        before do
          do_request method, api_path, headers: headers,
                     params: { access_token: access_token.token }
        end

        it 'returns status 403' do
          expect(response).to have_http_status(:forbidden)
        end

        it "can't delete question" do
          expect(Answer.count).to be 1
        end

        it 'returns empty body' do
          expect(response.body).to be_empty
        end
      end
    end
  end
end
