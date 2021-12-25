class NotificationsMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def new_answer(user, answer)
    @answer = answer
    mail to: user.email
  end
end
