defmodule GymRatsWeb.DeviceController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.DeviceView
  alias GymRats.Model.Device
  alias GymRats.Repo
  
  import Ecto.Query

  def create(conn, %{"token" => token} = params, account_id) do
    params = params |> Map.put("gym_rats_user_id", account_id)
    user_device = Device |> where([d], d.gym_rats_user_id == ^account_id) |> Repo.one
    token_device = Device |> where([d], d.token == ^token) |> Repo.one

    device = if user_device != nil && token_device != nil && user_device.id != token_device.id do
      user_device |> Repo.delete
      token_device
    else
      user_device || token_device || %Device{}
    end

    device = device |> Device.changeset(params) |> Repo.insert_or_update

    case device do
      {:ok, device} -> success(conn, DeviceView.default(device))
      {:error, _} -> failure(conn, "Something went wrong.")
    end
  end

  def delete_all(conn, _params, account_id) do
    Device 
    |> where([d], d.gym_rats_user_id == ^account_id) 
    |> Repo.delete_all

    success(conn, "Success.")
  end
end