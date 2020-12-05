defmodule GymRatsWeb.Rendering do
  import GymRatsWeb.ErrorHelpers
  import Phoenix.Naming
  import Plug.Conn

  @moduledoc """
  Rendering methods for success and failure responses.

  ## Example
  {
    "status": "success",
    "data": { ... }
  }
  """

  import Phoenix.Controller, only: [json: 2]

  @doc """
  Sends a successful response using json/2.
  Wraps the given data and sets status to "success"

  ## Examples

      iex> success(conn, %{name: "Harold"})

  """
  def success(conn, data) do
    json(conn, %{status: "success", data: data})
  end

  @doc """
  Sends a failure response using json/2.
  Wraps the given error and sets status to "failure"

  ## Examples

      iex> failure(conn, error: "Username is required.")

  """
  def failure(conn, error) when is_bitstring(error) do
    json(conn |> put_status(:unprocessable_entity), %{status: "failure", error: error})
  end

  @doc """
  Sends a failure response using json/2.
  Maps the list of errors on changeset to human readable form.

  ## Examples

      iex> failure(conn, error: "Username is required.")

  """
  def failure(conn, changeset) when is_map(changeset) do
    failure(conn, error_message(changeset))
  end

  defp error_message(changeset) do
    changeset.errors
    |> Enum.map(fn {key, error} ->
      humanize(key) <> " " <> translate_error(error)
    end)
    |> List.first()
  end
end
