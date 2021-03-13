feature 'Answer is edited' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given!(:question) { create(:question, author: user1) }
  given!(:answer) { create(:answer, question: question, author: user1) }

  describe 'by authenticated user' do
    describe 'being the author' do
      background do
        sign_in(user1)
        visit question_path(question)
        click_on 'Edit'
      end

      scenario 'without errors', js: true do
        within('.answers') do
          fill_in with: 'Updated answer', id: 'answer_body'
          click_on 'Update Answer'

          expect(page).to_not have_content answer.body
          expect(page).to have_content 'Updated answer'
          expect(page).to_not have_selector 'textarea'
        end
      end

      scenario 'with errors', js: true do
        within('.answers') do
          fill_in with: '', id: 'answer_body'
          click_on 'Update Answer'

          expect(page).to have_selector 'textarea'
        end
        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario 'non-author' do
      sign_in(user2)
      visit question_path(question)
      expect(page).not_to have_link 'Edit'
    end
  end

  scenario 'by unauthenticated user' do
    visit question_path(question)
    expect(page).not_to have_link 'Edit'
  end
end

