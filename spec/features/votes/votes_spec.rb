feature 'User' do
  given(:user1) { create :user }
  given(:user2) { create :user }
  given(:question) { create :question, author: user2 }
  given!(:answer) { create :answer, question: question, author: user2 }

  describe 'if authenticated' do
    describe 'if not author' do
      background { sign_in user1 }

      describe 'can vote' do
        describe 'only once' do
          scenario 'for the question', js: true do
            visit questions_path

            expect(page).to have_selector('a.vote-up-link')
            expect(page).to have_selector('a.vote-down-link')

            expect(find('span.result')).to have_content('0')

            find('a.vote-up-link').click
            expect(find('span.result')).to have_content('1')

            find('a.vote-up-link').click
            expect(find('span.result')).to have_content('1')
          end

          scenario 'for the answer', js: true do
            visit question_path(question)

            within "#answer_#{answer.id}" do
              expect(page).to have_selector('a.vote-up-link')
              expect(page).to have_selector('a.vote-down-link')

              expect(find('span.result')).to have_content('0')

              find('.vote-down-link').click
              expect(find('span.result')).to have_content('-1')

              find('.vote-down-link').click
              expect(find('span.result')).to have_content('-1')
            end
          end
        end
      end

      describe 'can change the vote to opposite', js: true do
        scenario 'for the question', js: true do
          visit questions_path

          find('a.vote-up-link').click
          expect(find('span.result')).to have_content('1')

          find('a.vote-down-link').click
          expect(find('span.result')).to have_content('-1')
        end

        scenario 'for the answer', js: true do
          visit question_path(question)

          within "#answer_#{answer.id}" do
            find('.vote-down-link').click
            expect(find('span.result')).to have_content('-1')

            find('.vote-up-link').click
            expect(find('span.result')).to have_content('1')
          end
        end
      end
    end

    describe 'if author' do
      background { sign_in user2 }

      describe 'cannot vote' do
        scenario 'for the question' do
          visit questions_path

          expect(page).not_to have_selector('a.vote-up-link')
          expect(page).not_to have_selector('a.vote-down-link')
        end

        scenario 'for the answer' do
          visit question_path(question)

          within "#answer_#{answer.id}" do
            expect(page).not_to have_selector('a.vote-up-link')
            expect(page).not_to have_selector('a.vote-down-link')
          end
        end
      end
    end
  end

  describe 'if not authenticated' do
    scenario 'cannot vote' do
      visit questions_path

      expect(page).not_to have_selector('a.vote-up-link')
      expect(page).not_to have_selector('a.vote-down-link')
    end
  end
end
