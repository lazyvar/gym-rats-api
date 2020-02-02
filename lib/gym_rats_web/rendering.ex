defmodule GymRatsWeb.Rendering do
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

      iex> failure(conn, %{message: "Uh-oh!", code: 333})

  """
  def failure(conn, error) do
    json(conn, %{status: "failure", error: error})
  end
end
