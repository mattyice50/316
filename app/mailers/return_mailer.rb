class ReturnMailer < ActionMailer::Base
  default from: "creightonvaughn@gmail.com"
  def return_email(user)
  	@email_content = EmailContent.last
  	mail(to: "creightonvaughn@gmail.com", subject: "Schedule Change for "+user.name)
  end
end
