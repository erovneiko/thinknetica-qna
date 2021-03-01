feature 'User can list questions' do
  given(:user) { create(:user) }
  given!(:question1) { create(:question, title: 'Question 1', author: user) }
  given!(:question2) { create(:question, title: 'Question 2', author: user) }
  given!(:question3) { create(:question, title: 'Question 3', author: user) }

  scenario 'User tries to list questions' do
    visit questions_path

    expect(page).to have_content 'Question 1'
    expect(page).to have_content 'Question 2'
    expect(page).to have_content 'Question 3'
  end
end
