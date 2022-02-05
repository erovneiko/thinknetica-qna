class SearchController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  SCOPE = %w[Question Answer Comment User]

  def search
    return unless params[:query]

    classes = params[:scope].permit!.to_h.keys.map { |c| c.constantize } if params[:scope]
    @results = ThinkingSphinx.search params[:query], classes: classes
    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
  end
end
