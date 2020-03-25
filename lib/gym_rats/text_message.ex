defmodule GymRats.TextMessage do
  alias GymRats.Repo
  alias GymRats.Model.Account

  require Logger

  def send_signup_text_to_mack(account) do
    Task.async(fn -> send_signup_text_to_mack_sync(account) end)
  end

  defp send_signup_text_to_mack_sync(account) do
    count = Repo.aggregate(Account, :count, :id)
    message = "#{account.full_name} is a Gym Rat! #{count} in the nest."

    if Application.get_env(:gym_rats, :environment) == :prod do
      ExTwilio.Message.create(
        to: "+14849476052",
        from: System.get_env("TWILIO_PHONE_NUMBER"),
        body: message
      )
    else
      Logger.info(message)
    end
  end
end
