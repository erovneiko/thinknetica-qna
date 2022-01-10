# Preview all emails at http://localhost:3000/rails/mailers/notifications
class NotificationsPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notifications/new_answer
  def new_answer
    NotificationsMailer.new_answer(User.first, Answer.first)
  end

end
