feature 'User can sign out the system' do
  given(:user) { create(:user) }

  scenario 'User tries to sign out the system' do
    visit new_user_session_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    expect(page).to have_content 'Signed in successfully.'

    click_on 'Exit'

    expect(page).to have_content 'Signed out successfully.'
  end
end
