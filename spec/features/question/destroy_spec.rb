feature 'User can delete question' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user1) }
  given!(:answer) { create(:answer, question: question, author: user1) }

  describe 'Authorized user' do
    scenario 'Author tries to delete his question', js: true do
      sign_in(user1)

      visit questions_path

      expect(page).to have_content 'Question title'

      accept_confirm { click_on 'Delete' }

      expect(page).not_to have_content 'Question title'
    end

    scenario 'Not author tries to delete the question' do
      sign_in(user2)

      visit questions_path

      expect(page).to have_content 'Question title'

      expect(page).not_to have_link 'Delete'
    end
  end

  describe 'Unauthorized user' do
    scenario 'tries to delete question at index page' do
      visit questions_path
      expect(page).not_to have_link 'Delete'
    end
  end
end
