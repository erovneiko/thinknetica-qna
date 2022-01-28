require 'sphinx_helper'

feature 'Search' do
  given(:user) { create(:user) }
  given!(:question) { create(:question, body: 'test', author: user) }

  scenario 'finds result', sphinx: true, js: true do
    visit search_path
    fill_in 'query', with: 'test'
    ThinkingSphinx::Test.run { click_on 'Search' }
    expect(find('.results')).to have_content 'test'
  end

  scenario 'does not find result', sphinx: true, js: true do
    visit search_path
    fill_in 'query', with: 'test'
    find_field('scope[Question]').set false
    find_field('scope[User]').set false
    ThinkingSphinx::Test.run { click_on 'Search' }
    expect(find('.results')).not_to have_content 'test'
  end
end

