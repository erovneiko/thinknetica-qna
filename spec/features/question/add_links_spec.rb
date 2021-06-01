feature 'User can add links to question', %q{
  In order to provide additional info to my question
  As an question's author
  I'd like to be able to add links
} do

  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/vkurennov/743f9367caa1039874af5a2244e1b44c' }
  given(:google_url) { 'https://google.com' }

  scenario 'User adds links when asks question', js: true do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text text text'

    click_on 'Add'

    within all('.nested-fields')[0] do
      all('input')[0].fill_in with: 'My gist'
      all('input')[1].fill_in with: gist_url
    end

    within all('.nested-fields')[1] do
      all('input')[0].fill_in with: 'Google'
      all('input')[1].fill_in with: google_url
    end

    click_on 'Create Question'
    click_link 'Show'

    expect(page).to have_selector "div.gist[data-src=\"#{gist_url+'.json'}\""
    expect(page).to have_link 'Google', href: google_url
  end
end
