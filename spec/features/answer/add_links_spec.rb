feature 'User can add links to answer', %q{
  In order to provide additional info to my answer
  As an question's author
  I'd like to be able to add links
} do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }
  given(:gist_url) { 'https://gist.github.com/vkurennov/743f9367caa1039874af5a2244e1b44c' }
  given(:google_url) { 'https://google.com' }

  scenario 'User adds link when give an answer', js: true do
    sign_in(user)

    visit question_path(question)

    fill_in with: 'My answer', id: 'answer_body'

    click_link 'Add'

    within all('.nested-fields')[0] do
      all('input')[0].fill_in with: 'My gist'
      all('input')[1].fill_in with: gist_url
    end

    within all('.nested-fields')[1] do
      all('input')[0].fill_in with: 'Google'
      all('input')[1].fill_in with: google_url
    end

    click_button 'Create Answer'

    within '.answers' do
      sleep 1
      expect(page).to have_selector "div.gist[data-src=\"#{gist_url+'.json'}\""
      expect(page).to have_link 'Google', href: google_url
    end
  end
end
