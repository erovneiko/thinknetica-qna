module FeatureHelpers
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'
  end

  def check_comment_creation(path)
    visit path
    click_on 'Comment'
    fill_in with: 'Comment Body', id: 'comment_body'
    click_on 'Create Comment'
    expect(current_path).to eq path
    within '.comments' do
      expect(page).to have_content 'Comment Body'
    end
  end

  def create_comment
    click_on 'Comment'

    fill_in with: 'Comment Body', id: 'comment_body'

    click_on 'Create Comment'

    within '.comments' do
      expect(page).to have_content 'Comment Body'
    end
  end
end
