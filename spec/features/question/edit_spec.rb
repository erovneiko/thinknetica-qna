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
        fill_in with: 'Updated title', id: 'question_title'
        fill_in with: 'Updated body', id: 'question_body'

        click_on 'Update Question'

        within '.questions' do
          expect(page).to_not have_content question.title
          expect(page).to_not have_selector 'textarea'
          expect(page).to have_content 'Updated title'
        end
      end

      scenario 'with attached files', js: true do
        attach_file ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"], id: 'question_files'

        click_on 'Update Question'
        click_link 'Edit'

        within '.questions' do
          expect(page).to have_link 'rails_helper.rb'
          expect(page).to have_link 'spec_helper.rb'
        end
      end

      scenario 'deleting file', js: true do
        attach_file ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"], id: 'question_files'

        click_on 'Update Question'
        click_link 'Edit'
        click_link id: "delete-file-#{question.files.first.id}"

        # save_and_open_page
        within '.questions' do
          expect(page).not_to have_link 'rails_helper.rb'
          expect(page).to have_link 'spec_helper.rb'
        end
      end

      scenario 'deleting link', js: true do
        within '.questions' do
          click_link 'Add'

          within '.nested-fields' do
            all('input')[0].fill_in with: 'google'
            all('input')[1].fill_in with: 'https://google.com'
          end

          click_button 'Update Question'
          click_link 'Show'
        end

        sleep 0.5
        click_link id: "delete-link-#{question.links.first.id}"
        expect(page).not_to have_link 'google'
      end

      scenario 'adding new link', js: true do
        within '.questions' do
          click_link 'Add'

          within '.nested-fields' do
            all('input')[0].fill_in with: 'google'
            all('input')[1].fill_in with: 'https://google.com'
          end

          click_button 'Update Question'
          click_link 'Show'
        end

        expect(page).to have_link 'google'
      end

      scenario 'with errors', js: true do
        fill_in with: '', id: 'question_title'
        fill_in with: '', id: 'question_body'

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
