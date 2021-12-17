feature 'User can sign up' do
  given(:user) { create(:user) }

  background { visit new_user_registration_path }

  scenario 'Unique user tries to sign up' do
    fill_in 'Email', with: 'q@q.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'

    click_on 'Sign up'

    expect(page.text).to match /A message with a confirmation link has been sent to your email/
  end

  scenario 'Already existed user tries to sign up' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password_confirmation

    click_on 'Sign up'

    expect(page).to have_content 'Email has already been taken'
  end
end
