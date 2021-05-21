defmodule GymRats.Pigeon do
  def apns_config do
    Pigeon.APNS.ConfigParser.parse(
      key: System.get_env("APNS_TOKEN"),
      key_identifier: "FW985G67H6",
      team_id: "24MV8D7ZU8",
      mode: System.get_env("APNS_MODE") |> String.to_atom(),
      name: :apns_default
    )
  end

  def fcm_config do
    Pigeon.FCM.Config.new(name: :fcm_default, key: System.get_env("FCM_SERVER_KEY"))
  end
end
