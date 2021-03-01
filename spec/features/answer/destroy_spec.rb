feature 'User can delete answer' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user1) }
  given!(:answer) { create(:answer, question: question, author: user1) }

  scenario 'User tries to delete his answer' do
    sign_in(user1)

    visit question_path(question)

    click_on 'Delete answer'

    expect(page).to have_content 'Answer successfully deleted'
  end

  scenario 'User tries to delete foreign answer' do
    sign_in(user2)

    visit question_path(question)

    expect(page).not_to have_content 'Delete answer'
  end
end
