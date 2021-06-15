feature 'User can create question with award' do
  given(:user) { create(:user) }

  background do
    sign_in(user)
    visit questions_path
    click_on 'Ask'
  end

  scenario 'asks a question with award' do
    fill_in 'Title', with: 'Question with award'
    fill_in 'Body', with: 'Best answer will get award'

    fill_in 'Award', with: 'Award name'
    attach_file "#{Rails.root}/tmp/badge_01.png", id: 'question_award_attributes_image'

    click_on 'Create Question'

    expect(page).to have_content 'Your question successfully created'
    expect(page).to have_content 'Question with award'
    expect(page).to have_content 'Best answer will get award'

    expect(Question.first.award).to be_an_instance_of(Award)
    expect(Question.first.award.name).to eq('Award name')
    expect(Question.first.award.image.attachment.blob.filename).to eq('badge_01.png')
  end
end
