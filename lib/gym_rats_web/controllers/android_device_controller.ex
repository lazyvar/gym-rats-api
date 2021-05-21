defmodule GymRatsWeb.AndroidDeviceController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.DeviceView
  alias GymRats.Model.AndroidDevice
  alias GymRats.Repo

  import Ecto.Query

  def create(conn, params, account_id) do
    params = params |> Map.put("account_id", account_id)
    devices = AndroidDevice |> where([d], d.account_id == ^account_id) |> Repo.all()
    device = devices |> List.first() || %AndroidDevice{}
    device = device |> AndroidDevice.changeset(params) |> Repo.insert_or_update()
    devices = devices |> List.delete_at(0)

    unless Enum.empty?(devices) do
      devices |> Enum.each(fn d ->
        d |> Repo.delete()
      end)
    end

    case device do
      {:ok, device} -> success(conn, DeviceView.default(device))
      {:error, device} -> failure(conn, device)
    end
  end

  def delete_all(conn, _params, account_id) do
    AndroidDevice
    |> where([d], d.account_id == ^account_id)
    |> Repo.delete_all()

    success(conn, "Success.")
  end
end
