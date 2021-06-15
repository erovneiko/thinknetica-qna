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

      scenario 'with attached files', js: true do
        within '.answers' do
          attach_file ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"], id: 'answer_files'

          click_on 'Update Answer'
          click_link 'Edit'

          expect(page).to have_link 'rails_helper.rb'
          expect(page).to have_link 'spec_helper.rb'
        end
      end

      scenario 'deleting link', js: true do
        within '.answers' do
          click_link 'Add'

          within '.nested-fields' do
            all('input')[0].fill_in with: 'google'
            all('input')[1].fill_in with: 'https://google.com'
          end

          click_button 'Update Answer'

          click_link 'Edit'
          click_link id: "delete-link-#{answer.links.first.id}"

          expect(page).not_to have_link 'google'
        end
      end

      scenario 'adding new link', js: true do
        within '.answers' do
          click_link 'Add'

          within '.nested-fields' do
            all('input')[0].fill_in with: 'google'
            all('input')[1].fill_in with: 'https://google.com'
          end

          click_button 'Update Answer'
          click_link 'Edit'

          expect(page).to have_link 'google'
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

