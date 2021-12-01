RSpec.describe FilesController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }

  describe 'DELETE #destroy' do
    before do
      question.files.attach fixture_file_upload("#{Rails.root}/spec/rails_helper.rb")
    end

    context 'authorized user' do
      context 'author' do
        before { login(user) }

        it 'deletes file' do
          expect do
            delete :destroy, params: { id: question.files.first.id }, format: :js
          end.to change(question.files, :count).by(-1)
        end

        it 'assigns deleted file to attribute @file' do
          file = question.files.first
          delete :destroy, params: { id: question.files.first.id }, format: :js
          expect(assigns(:file)).to eq file
        end

        it 'renders ajax answer' do
          delete :destroy, params: { id: question.files.first.id }, format: :js
          expect(response).to render_template :destroy
        end
      end

      context 'not author' do
        let(:another_user) { create(:user) }
        before { login(another_user) }

        it 'cannot delete file' do
          expect do
            delete :destroy, params: { id: question.files.first.id }, format: :js
          end.not_to change(question.files, :count)
        end

        it 'returns status forbidden' do
          delete :destroy, params: { id: question.files.first.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'unauthorized user' do
      it 'cannot delete file' do
        expect do
          delete :destroy, params: { id: question.files.first.id }, format: :js
        end.not_to change(question.files, :count)
      end

      it 'returns status unauthorized' do
        delete :destroy, params: { id: question.files.first.id }, format: :js
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
