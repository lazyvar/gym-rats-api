defmodule GymRats.Mail.ResetPassword do
  import Bamboo.Email

  def email(to, token) do
    text_body = """
    Hi #{to.full_name},

    Please go to https://www.gymrats.app/reset-password?token=#{token} to reset your password. After 30 minutes, this link will expire.

    GymRats MailBot
    """

    html_body = """
    <p>Hi #{to.full_name},</p>
    <p>Please go to <a href="https://www.gymrats.app/reset-password?token=#{token}">https://www.gymrats.app/reset-password?token=#{
      token
    }</a> to reset your password. After 30 minutes, this link will expire.</p>
    <p>GymRats MailBot<p>
    """

    new_email(
      to: to.email,
      from: "GymRats MailBot <beepboop@gymrats.app>",
      subject: "Reset password",
      html_body: html_body,
      text_body: text_body
    )
  end
end
