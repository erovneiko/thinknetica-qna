feature 'User can view question and its answers' do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given!(:answer1) { create(:answer, body: 'Answer 1', question: question, author: user) }
  given!(:answer2) { create(:answer, body: 'Answer 2', question: question, author: user) }
  given!(:answer3) { create(:answer, body: 'Answer 3', question: question, author: user) }

  scenario 'User tries to view question and its answers' do
    visit question_path(question)

    expect(page).to have_content 'Answer 1'
    expect(page).to have_content 'Answer 2'
    expect(page).to have_content 'Answer 3'
  end
end
