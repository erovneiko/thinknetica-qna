RSpec.describe SearchController, type: :controller do
  describe 'GET #search' do
    let(:search_results) { ThinkingSphinx::Search.new }

    before do
      allow(ThinkingSphinx).to receive(:search).and_return(search_results)
    end

    it 'does not search if not query' do
      expect(ThinkingSphinx).not_to receive(:search)
      get :search
    end

    it 'calls sphinx if query' do
      expect(ThinkingSphinx).to receive(:search).with('test', classes: nil)
      get :search, params: { query: 'test' }
    end

    it 'takes into account search classes' do
      SearchController::SCOPE.each do |scope|
        expect(ThinkingSphinx).to receive(:search).with('test', classes: [scope.constantize])
        get :search, params: { query: 'test', scope: { scope => '1' } }
      end
    end

    it 'assigns search result to @results' do
      get :search, params: { query: 'test' }
      expect(assigns(:results)).to eq search_results
    end

    it 'renders search view' do
      get :search, params: { query: 'test' }
      expect(response).to render_template :search
    end
  end
end
