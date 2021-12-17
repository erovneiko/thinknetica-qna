require 'rails_helper'

describe 'Profiles API', type: :request do
  let(:me) { create(:user) }
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/profiles/me' do
    let(:method) { :get }
    let(:api_path) { me_api_v1_profiles_path }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token }
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns all public fields' do
        %w[id email created_at updated_at].each do |attr|
          expect(json['user'][attr]).to eq me.send(attr).as_json
        end
      end

      it 'does not return private fields' do
        %w[password encrypted_password].each do |attr|
          expect(json).to_not have_key(attr)
        end
      end
    end
  end

  describe 'GET /api/v1/profiles/all' do
    let(:method) { :get }
    let(:api_path) { all_api_v1_profiles_path }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      let!(:users) { create_list(:user, 2) }
      let(:users_response) { json['users'] }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before do
        do_request method, api_path, headers: headers,
                   params: { access_token: access_token.token }
      end

      it 'returns status 200' do
        expect(response).to be_successful
      end

      it 'returns public fields' do
        %w[id email created_at updated_at].each do |attr|
          expect(users_response.first[attr]).to eq users.first.send(attr).as_json
        end
      end

      it 'does not return private fields' do
        %w[password encrypted_password].each do |attr|
          expect(json).to_not have_key(attr)
        end
      end

      it 'returns users' do
        users.each do |user|
          expect(users_response).to include(user.as_json)
        end
      end

      it 'does not return me' do
        expect(users_response).not_to include(me.as_json)
      end
    end
  end
end
