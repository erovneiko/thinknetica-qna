RSpec.describe LinksController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let!(:link) { create(:link, linkable: question, name: 'google', url: 'https://google.com') }

  describe 'DELETE #destroy' do
    context 'authorized user' do
      context 'author' do
        before { login(user) }

        it 'deletes link' do
          expect do
            delete :destroy, params: { id: question.links.first.id }, format: :js
          end.to change(question.links, :count).by(-1)
        end

        it 'assigns deleted link to attribute @link' do
          link = question.links.first
          delete :destroy, params: { id: question.links.first.id }, format: :js
          expect(assigns(:link)).to eq link
        end

        it 'renders ajax answer' do
          delete :destroy, params: { id: question.links.first.id }, format: :js
          expect(response).to render_template :destroy
        end
      end

      context 'not author' do
        let(:another_user) { create(:user) }
        before { login(another_user) }

        it 'cannot delete link' do
          expect do
            delete :destroy, params: { id: question.links.first.id }, format: :js
          end.not_to change(question.links, :count)
        end

        it 'returns authorization error' do
          delete :destroy, params: { id: question.links.first.id }, format: :js
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        end
      end
    end

    context 'unauthorized user' do
      it 'cannot delete link' do
        expect do
          delete :destroy, params: { id: question.links.first.id }, format: :js
        end.not_to change(question.links, :count)
      end

      it 'returns status unauthorized' do
        delete :destroy, params: { id: question.links.first.id }, format: :js
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
