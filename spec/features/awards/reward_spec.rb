feature 'Answer is chosen as the best' do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, author: user1) }
  given!(:answer1) { create(:answer, question: question, author: user2) }
  given!(:answer2) { create(:answer, question: question, author: user2) }
  before { question.create_award(name: 'Award name', image: fixture_file_upload("#{Rails.root}/tmp/badge_01.png")) }

  scenario 'award goes to the author of answer', js: true do
    sign_in user1
    visit question_path(question)

    node1 = find("div#answer-#{answer1.id}")

    within node1 do
      click_link 'Best'
    end

    expect(node1).to have_selector '.best'

    visit questions_path
    click_link 'Exit'

    sign_in user2
    visit questions_path

    click_link 'Awards'

    expect(page).to have_content question.title
    expect(page).to have_content 'Award name'
    expect(page).to have_selector "img[src=\"#{url_for(question.award.image).delete_prefix('http://www.example.com')}\"]"
  end
end
