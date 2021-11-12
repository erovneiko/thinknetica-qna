feature 'Authentication via Github' do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({ provider: 'github', uid: '123',
                                                                  info: { email: '456' } })
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
  end

  scenario 'successfully'
  scenario 'invalid credentials'

  # let!(:user) { create(:user) }
  # # let(:question_params) { build(:question, title: 'MyString', body: 'MyText') }
  #
  # before do
  #   OmniAuth.config.test_mode = true
  #   visit root_path
  #   click_on 'Login'
  #   mock_auth_hash(:vkontakte)
  # end
  #
  # describe 'update email' do
  #   let(:user) { create :user, email: 'change-email@email.com' }
  #   before { click_on 'Sign in with Vkontakte' }
  #
  #   scenario 'successfuly' do
  #     fill_in 'auth_info_email', with: 'test@test.com'
  #     click_on 'Submit'
  #     expect(page).to have_content 'Successfully authenticated from Vkontakte account'
  #
  #     click_on 'Sign out'
  #     click_on 'Sign in'
  #     click_on 'Sign in with Vkontakte'
  #
  #     click_on 'Ask question'
  #     fill_in 'Title', with: question_params.title
  #     fill_in 'Body', with: question_params.body
  #
  #     click_on 'Create'
  #
  #     expect(page).to have_content 'Question was successfully created.'
  #     expect(page).to have_content question_params.title
  #     expect(page).to have_content question_params.body
  #   end
  #
  #   scenario 'when it has not been updated' do
  #     click_on 'Submit'
  #     expect(page).to have_content 'Email is required to compete sign up'
  #   end
  # end
  #
  # scenario 'with invalid credentials' do
  #   OmniAuth.config.mock_auth[:vkontakte] = :invalid_credentials
  #   click_on 'Sign in with Vkontakte'
  #   expect(page).to have_content 'Could not authenticate you from Vkontakte because "Invalid credentials"'
  # end
end
