feature 'User can delete question' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user1) }
  given!(:answer) { create(:answer, question: question, author: user1) }

  describe 'Authorized user' do
    scenario 'Author tries to delete his question' do
      sign_in(user1)

      visit question_path(question)

      expect(page).to have_content 'Question Title'
      expect(page).to have_content 'Question Body'

      click_on 'Delete question'

      expect(page).to have_content 'Question successfully deleted'
    end

    scenario 'Not author tries to delete the question' do
      sign_in(user2)

      visit question_path(question)

      expect(page).to have_content 'Question Title'
      expect(page).to have_content 'Question Body'

      expect(page).not_to have_content 'Delete question'
    end
  end

  scenario 'Unauthorized user tries to delete question' do
    visit question_path(question)

    expect(page).not_to have_content 'Delete question'
  end
end
