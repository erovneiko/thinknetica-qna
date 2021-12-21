require 'rails_helper'

describe 'Questions API', type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json',
                    'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions' do
    let(:method) { :get }
    let(:api_path) { api_v1_questions_path }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let(:questions) { create_list(:question, 2, author: user) }
      let(:question) { questions.first }
      let!(:answers) { create_list(:answer, 3, question: question, author: user) }
      let(:question_response) { json['questions'].first }
      let(:answer_response) { json['questions']['answers'].first }
      let(:access_token) { create(:access_token) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token }
      end

      it 'returns status 200' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(json['questions'].size).to eq 2
      end

      it 'returns all public fields' do
        %w[id author_id title body created_at updated_at].each do |attr|
          expect(question_response[attr]).to eq question.send(attr).as_json
        end
      end

      it 'contains user object' do
        expect(question_response['author']['id']).to eq question.author.id
      end

      it 'contains short title' do
        expect(question_response['short_title']).to eq question.title.truncate(7)
      end

      describe 'answers' do
        let(:answer) { answers.first }
        let(:answer_response) { question_response['answers'].first }

        it 'returns list of answers' do
          expect(question_response['answers'].size).to eq 3
        end

        it 'returns all public fields' do
          %w[id author_id body question_id created_at updated_at].each do |attr|
            expect(answer_response[attr]).to eq answer.send(attr).as_json
          end
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let(:method) { :get }
    let(:api_path) { api_v1_question_path(question) }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let!(:answers) { create_list(:answer, 3, question: question, author: user) }
      let!(:answer) { answers.first }
      let(:question_response) { json['question'] }
      let(:answer_response) { json['question']['answers'].first }
      let(:access_token) { create(:access_token) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token }
      end

      it 'returns status 200' do
        expect(response).to be_successful
      end

      it 'returns questions fields' do
        %w[id author_id title body created_at updated_at].each do |attr|
          expect(question_response[attr]).to eq question.send(attr).as_json
        end
      end

      it 'returns list of answers' do
        expect(question_response['answers'].size).to eq 3
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
    let(:api_path) { api_v1_questions_path }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let(:access_token) { create(:access_token) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token,
                             question: attributes_for(:question) }
      end

      it 'returns status 201' do
        expect(response).to be_successful
      end

      it 'creates new question' do
        expect(Question.count).to be 1
      end

      it 'returns new question id' do
        expect(json['question']['id']).to be
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:method) { :patch }
    let(:api_path) { api_v1_question_path(question) }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      context 'author' do
        let(:access_token) { create(:access_token, resource_owner_id: user.id) }

        before do
          do_request method, api_path, headers: headers,
                     params: { access_token: access_token.token,
                               question: { title: 'Updated', body: 'Updated' } }
        end

        it 'returns status 202' do
          expect(response).to be_successful
        end

        it 'updates question' do
          question.reload
          expect(question.title).to eq 'Updated'
          expect(question.body).to eq 'Updated'
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
                               question: { title: 'Updated', body: 'Updated' } }
        end

        it 'returns status 403' do
          expect(response).to have_http_status(:forbidden)
        end

        it "can't update question" do
          expect(question.title).not_to be 'Updated'
          expect(question.body).not_to be 'Updated'
        end

        it 'returns empty body' do
          expect(response.body).to be_empty
        end
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:method) { :delete }
    let(:api_path) { api_v1_question_path(question) }

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
          expect(Question.count).to be_zero
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
                               question: attributes_for(:question) }
        end

        it 'returns status 403' do
          expect(response).to have_http_status(:forbidden)
        end

        it "can't delete question" do
          expect(Question.count).to be 1
        end

        it 'returns empty body' do
          expect(response.body).to be_empty
        end
      end
    end
  end
end
