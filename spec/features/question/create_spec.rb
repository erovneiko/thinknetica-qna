feature 'User can create question', "
  In order to get answer from a community
  As an authenticated user
  I'd like to be able to ask the question
" do

  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit questions_path

      click_on 'Ask'
    end

    scenario 'asks a question' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'text text text'

      click_on 'Create Question'

      expect(page).to have_content 'Your question successfully created'
      expect(page).to have_content 'Test question'
      expect(page).to have_content 'text text text'
    end

    scenario 'asks a question with errors' do
      click_on 'Create Question'

      expect(page).to have_content "Title can't be blank"
    end

    scenario 'asks a question with attached files' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'text text text'

      attach_file ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"], id: 'question_files'

      click_on 'Create Question'
      click_link 'Show'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end
  end

  scenario 'with cable', js: true do
    Capybara.using_session('user') do
      sign_in(user)
      visit questions_path
    end

    Capybara.using_session('guest') do
      visit questions_path
    end

    Capybara.using_session('user') do
      click_on 'Ask'

      fill_in 'Title', with: 'Title'
      fill_in 'Body', with: 'Body'

      click_on 'Create Question'

      expect(page).to have_content 'Title'
    end

    Capybara.using_session('guest') do
      expect(page).to have_content 'Title'
    end
  end

  scenario 'Unauthenticated user tries to ask a question' do
    visit questions_path
    expect(page).not_to have_link 'Ask'
  end
end
