feature 'Answer can be deleted' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user1) }
  given!(:answer) { create(:answer, question: question, author: user1) }

  describe 'by authorized user' do
    scenario 'being the author', js: true do
      sign_in(user1)

      visit question_path(question)

      expect(page).to have_content 'Answer body'

      accept_confirm { click_on 'Delete' }

      expect(page).not_to have_content 'Answer Body'
    end

    scenario 'being non-author' do
      sign_in(user2)

      visit question_path(question)

      expect(page).to have_content 'Answer body'
      expect(page).not_to have_link 'Delete'
    end
  end

  scenario 'Answer can\'t be deleted by unauthorized user' do
    visit question_path(question)

    expect(page).not_to have_link 'Delete'
  end
end
