RSpec.describe CommentsController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, author: user2) }
  let(:answer) { create(:answer, question: question, author: user2) }

  describe 'GET #new' do
    context 'authorized user' do
      context 'author of commentable' do
        before { login(user2) }
        before { get :new, params: { question_id: question.id } }

        it 'returns authorization error' do
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        end
      end

      context 'not an author of commentable' do
        before { login(user1) }
        before { get :new, params: { question_id: question.id } }

        it 'assigns a new Comment to @comment' do
          expect(assigns(:comment)).to be_a_new(Comment)
        end

        it 'renders new view' do
          expect(response).to render_template :new
        end
      end
    end

    context 'unauthorized user' do
      before { get :new, params: { question_id: question.id } }

      it 'redirects to login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #create' do
    context 'authorized user' do
      context 'author of commentable' do
        before do
          login(user2)
          post :create, params: {
            question_id: question.id,
            comment: attributes_for(:comment)
          }
        end

        it 'does not save the comment' do
          expect do
            post :create, params: {
              question_id: question.id,
              comment: attributes_for(:comment)
            }
          end.to_not change(Comment, :count)
        end

        it 'returns authorization error' do
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        end
      end

      context 'not an author of commentable' do
        before { login(user1) }

        context 'with valid attributes' do
          it 'saves a new comment in the database' do
            expect do
              post :create, params: {
                question_id: question.id,
                comment: attributes_for(:comment)
              }
            end.to change(Comment, :count).by(1)
          end

          it 'redirects question to questions page' do
            post :create, params: {
              question_id: question.id,
              comment: attributes_for(:comment)
            }
            expect(response).to redirect_to questions_path
          end

          it 'redirects answer to question page' do
            post :create, params: {
              answer_id: answer.id,
              comment: attributes_for(:comment)
            }
            expect(response).to redirect_to question_path(question)
          end
        end

        context 'with invalid attributes' do
          it 'does not save the comment' do
            expect do
              post :create, params: {
                question_id: question.id,
                comment: attributes_for(:comment, :invalid)
              }
            end.to_not change(Comment, :count)
          end

          it 're-renders view' do
            post :create, params: {
              question_id: question.id,
              comment: attributes_for(:comment, :invalid)
            }
            expect(response).to render_template :new
          end
        end
      end
    end

    context 'unauthorized user' do
      it 'does not save the comment' do
        expect do
          post :create, params: {
            question_id: question.id,
            comment: attributes_for(:comment)
          }
        end.to_not change(Comment, :count)
      end

      it 'redirects to login page' do
        post :create, params: {
          question_id: question.id,
          comment: attributes_for(:comment)
        }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
