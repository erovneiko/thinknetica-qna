feature 'User can list questions' do
  given(:user) { create(:user) }
  given!(:questions) { create_list(:questions_list, 3, author: user) }

  scenario 'User tries to list questions' do
    visit questions_path

    1.upto(3) { |i| expect(page).to have_content "Question #{i}" }
  end
end
