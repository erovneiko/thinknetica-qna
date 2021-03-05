feature 'User can view question and its answers' do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given!(:answers) { create_list(:answers_list, 3, question: question, author: user) }

  scenario 'User tries to view question and its answers' do
    visit question_path(question)

    1.upto(3) { |i| expect(page).to have_content "Answer #{i}" }
  end
end
