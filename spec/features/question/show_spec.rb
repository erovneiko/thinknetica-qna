feature 'User can answer the question' do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit question_path(question)
    end

    scenario 'creates answer to the question' do
      fill_in 'Answer', with: 'Answer Body'
      click_on 'Reply'

      expect(page).to have_content 'Answer successfully created'
      expect(page).to have_content 'Question Title'
      expect(page).to have_content 'Question Body'
      expect(page).to have_content 'Answer Body'
    end

    scenario 'creates empty answer to the question' do
      click_on 'Reply'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user creates answer to the question' do
    visit question_path(question)

    expect(page).not_to have_content 'Reply'
  end
end
