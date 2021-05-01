feature 'Question can be edited' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given!(:question) { create(:question, author: user1) }

  describe 'by authenticated user' do
    describe 'being the author' do
      background do
        sign_in(user1)
        visit questions_path
        click_on 'Edit'
      end

      scenario 'without errors', js: true do
        fill_in 'Title', with: 'Updated title'
        fill_in 'Body', with: 'Updated body'

        click_on 'Update Question'

        within '.questions' do
          expect(page).to_not have_content question.title
          expect(page).to_not have_selector 'textarea'
          expect(page).to have_content 'Updated title'
        end
      end

      scenario 'with errors', js: true do
        fill_in 'Title', with: ''
        fill_in 'Body', with: ''

        click_on 'Update Question'

        expect(page).to have_content "Title can't be blank"
        expect(page).to have_content "Body can't be blank"
        expect(page).to have_selector 'textarea'
      end
    end

    scenario 'non-author' do
      sign_in(user2)
      visit questions_path
      expect(page).not_to have_link 'Edit'
    end
  end

  scenario 'by unauthenticated user' do
    visit questions_path
    expect(page).not_to have_link 'Edit'
  end
end
