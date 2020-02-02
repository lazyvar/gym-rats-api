defmodule GymRatsWeb.DeviceView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(id token)a

  def default(challenge) do
    challenge |> keep(@default_attrs)
  end
end
