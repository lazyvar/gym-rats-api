defmodule GymRatsWeb.JSONView do
  def keep(struct, attrs) do
    struct
    |> Map.drop([:__meta__, :__struct__])
    |> Map.take(attrs)
  end
end
