class OauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :find_auth, only: %i[github mail_ru vkontakte enter_email]
  before_action :sign_in_from_oauth, only: %i[github mail_ru vkontakte enter_email]

  def github
  end

  def mail_ru
  end

  def vkontakte
  end

  def enter_email
  end

  private

  def sign_in_from_oauth
    @user = User.find_for_oauth(@auth)

    if @user&.persisted?
      confirm_email(@user) if action_name == 'enter_email'
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: @auth.provider) if is_navigational_format?

    elsif !@auth.info.email
      render_email_view
    else
      redirect_to root_path, alert: 'Something went wrong'
    end
  end

  def find_auth
    @auth = request.env['omniauth.auth']
    return if @auth

    @auth = OmniAuth::AuthHash.new(session[:auth])
    @auth.info.email = params[:email]
    session.delete :auth
  end

  def render_email_view
    session[:auth] = @auth
    flash.now[:notice] = 'Пожалуйста, укажите ваш Email'
    render 'oauth_callbacks/enter_email'
  end

  def confirm_email(user)
    user.update(confirmed_at: nil)
    user.send_confirmation_instructions
  end
end
