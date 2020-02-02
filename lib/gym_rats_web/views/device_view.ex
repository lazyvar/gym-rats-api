defmodule GymRatsWeb.DeviceView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(id token)a

  def default(device) do
    device |> keep(@default_attrs)
  end
end
