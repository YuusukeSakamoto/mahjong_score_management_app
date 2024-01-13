# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact_mail(contact, user)
    @contact = contact
    mail to: user.email, bcc: ENV['SEND_MAIL'], subject: 'お問い合わせについて【自動送信】'
  end
end
