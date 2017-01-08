class NoticeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.sendmail_gcales.subject
  #
  def sendmail_for_users_by_project(user)
    @user = user
    mail to: user[:email],
    subject: 'プロジェクト工数確認メール'
  end

  def sendmail_for_users_by_working_time(user)
    @user = user
    mail to: user[:email],
    subject: '月間勤務時間確認メール'
  end
end
