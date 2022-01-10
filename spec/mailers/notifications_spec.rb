require "rails_helper"

RSpec.describe NotificationsMailer, type: :mailer do
  describe "new_answer" do
    let(:user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let(:answer) { create(:answer, question: question, author: user) }
    let(:mail) { NotificationsMailer.new_answer(user, answer) }

    it "renders the headers" do
      expect(mail.subject).to eq("New answer")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(answer.body)
      expect(mail.body.encoded).to match(question.title)
    end
  end

end
