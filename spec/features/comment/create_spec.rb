feature 'Comment creation' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user2) }
  given!(:answer) { create(:answer, question: question, author: user2) }

  describe 'by authenticated user not being author of the' do
    background { sign_in user1 }

    scenario 'question' do
      visit questions_path
      create_comment
      expect(current_path).to eq questions_path
    end

    scenario 'answer' do
      visit question_path(question)
      create_comment
      expect(current_path).to eq question_path(question)
    end
  end

  describe 'not possible by authenticated user being author of the' do
    background { sign_in user2 }

    scenario 'question' do
      visit questions_path
      expect(page).not_to have_link 'Comment'
    end

    scenario 'answer' do
      visit question_path(question)
      expect(page).not_to have_link 'Comment'
    end
  end

  describe 'for not authenticated user not possible for the' do
    scenario 'question' do
      visit questions_path
      expect(page).not_to have_link 'Comment'
    end

    scenario 'answer' do
      visit question_path(question)
      expect(page).not_to have_link 'Comment'
    end
  end

  scenario 'with empty body not possible' do
    sign_in user1
    visit questions_path
    click_on 'Comment'
    click_on 'Create Comment'
    expect(page).to have_content "Body can't be blank"
  end

  scenario 'with cable', js: true do
    Capybara.using_session('user') do
      sign_in(user1)
      visit question_path(question)
    end

    Capybara.using_session('guest') do
      visit question_path(question)
    end

    Capybara.using_session('user') do
      create_comment
    end

    Capybara.using_session('guest') do
      within '.comments' do
        expect(page).to have_content 'Comment Body'
      end
    end
  end
end
