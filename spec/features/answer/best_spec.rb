feature 'Answer can be chosen as the best -' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user1) }
  given!(:answer1) { create(:answer, question: question, author: user2) }
  given!(:answer2) { create(:answer, question: question, author: user2) }

  describe 'by authenticated user' do
    scenario 'being the author of the question', js: true do
      sign_in user1
      visit question_path(question)

      node1 = find("div#answer-#{answer1.id}")
      node2 = find("div#answer-#{answer2.id}")

      within node1 do
        click_on 'Best'
      end

      expect(node1).to have_selector '.best'
      expect(node1).not_to have_link 'Best'

      within node2 do
        click_on 'Best'
      end

      expect(node1).not_to have_selector '.best'
      expect(node1).to have_link 'Best'

      expect(node2).to have_selector '.best'
      expect(node2).not_to have_link 'Best'

      expect(node2).to appear_before node1
      # save_and_open_page
    end

    scenario 'being non-author of question' do
      sign_in user2
      visit question_path(question)
      expect(page).not_to have_link 'Best'
    end
  end

  scenario 'by unauthenticated user' do
    visit question_path(question)
    expect(page).not_to have_link 'Best'
  end
end
