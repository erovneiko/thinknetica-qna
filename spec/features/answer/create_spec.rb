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

    scenario 'creates answer with attached files', js: true do
      fill_in with: 'Answer Body', id: 'answer_body'

      attach_file ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"], id: 'answer_files'

      click_on 'Create Answer'

      # save_and_open_page
      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end
  end

  scenario 'with cable', js: true do
    Capybara.using_session('user') do
      sign_in(user)
      visit question_path(question)
    end

    Capybara.using_session('guest') do
      visit question_path(question)
    end

    Capybara.using_session('user') do
      fill_in with: 'Answer Body', id: 'answer_body'

      click_on 'Create Answer'

      expect(current_path).to eq question_path(question)

      within '.answers' do
        expect(page).to have_content 'Answer Body'
      end
    end

    Capybara.using_session('guest') do
      within '.answers' do
        expect(page).to have_content 'Answer Body'
      end
    end
  end

  scenario 'Unauthenticated user creates answer to the question' do
    visit question_path(question)

    expect(page).not_to have_content 'Create Answer'
  end
end
