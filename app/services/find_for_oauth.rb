class Services::FindForOauth
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  def call
    authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s).first
    return authorization.user if authorization

    email = auth.info.email
    return nil unless email

    user = User.where(email: email).first
    user ||= create_user(email)

    user.create_authorization(auth)
    user
  end

  private

  def create_user(email)
    password = Devise.friendly_token[0, 20]
    user = User.new(email: email, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save!
    user
  end
end
