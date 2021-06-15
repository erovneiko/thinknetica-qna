RSpec.describe AwardsController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question1) { create(:question, author: user1) }
  let(:question2) { create(:question, author: user1) }
  let(:answer1) { create(:answer, question: question1, author: user2) }
  let(:answer2) { create(:answer, question: question1, author: user2) }
  let(:answer3) { create(:answer, question: question2, author: user2) }
  let(:answer4) { create(:answer, question: question2, author: user2) }
  let!(:award1) { question1.create_award(name: 'Award1', image: fixture_file_upload("#{Rails.root}/tmp/badge_01.png")) }
  let!(:award2) { question2.create_award(name: 'Award2', image: fixture_file_upload("#{Rails.root}/tmp/badge_02.png")) }

  before do
    question1.best_answer = answer1
    question2.best_answer = answer4
    question1.save
    question2.save
  end

  describe 'GET #index' do
    context 'authorized user' do
      before do
        login(user2)
        get :index
      end

      it 'populates current user awards' do
        expect(assigns(:awards)).to match_array([award1, award2])
      end

      it 'renders index view' do
        expect(response).to render_template :index
      end
    end

    context 'Unauthorized user' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
