feature 'User can answer the question' do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'creates answer to the question', js: true do
      fill_in with: 'Answer Body', id: 'answer_body'

      click_on 'Create Answer'

      expect(current_path).to eq question_path(question)

      within '.answers' do
        expect(page).to have_content 'Answer Body'
      end
    end

    scenario 'creates answer with errors', js: true do
      click_on 'Create Answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user creates answer to the question' do
    visit question_path(question)

    expect(page).not_to have_content 'Create Answer'
  end
end
