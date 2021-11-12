require 'capybara/email/rspec'

feature 'Oauth authentication' do
  background do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({ provider: 'github', uid: '123', info: { email: 'test@test.com' } })
    OmniAuth.config.mock_auth[:vkontakte] = OmniAuth::AuthHash.new({ provider: 'vkontakte', uid: '123', info: { email: nil } })
    clear_emails

    visit root_path
    click_on 'Login'

    expect(page).to have_content 'Log in'
    expect(User.count).to be 0
  end

  scenario 'via Github' do
    click_on 'Sign in with GitHub'

    expect(User.count).to be 1
    expect(User.first.email).to be
    expect(User.first.confirmed_at).to be

    expect(page).to have_content 'Successfully authenticated from github account.'
    # save_and_open_page
  end

  scenario 'via Vkontakte' do
    click_on 'Sign in with Vkontakte'

    expect(page).to have_content 'Пожалуйста, укажите ваш Email'
    fill_in 'Email', with: 'test@test.com'
    click_on 'Save'

    expect(page).to have_content 'You have to confirm your email address before continuing.'
    expect(User.count).to be 1
    expect(User.first.email).to be
    expect(User.first.confirmed_at).to be_nil

    open_email('test@test.com')
    expect(current_email.subject).to have_content 'Confirmation instructions'
    current_email.click_link 'Confirm my account'

    expect(page).to have_content 'Your email address has been successfully confirmed.'
    expect(User.first.confirmed_at).to be

    expect(page).to have_content 'Log in'
    click_on 'Sign in with Vkontakte'

    expect(page).to have_content 'Successfully authenticated from vkontakte account.'
    # save_and_open_page
  end
end
