defmodule GymRats.Query.ChallengeQuery do
  import Ecto.Query, only: [where: 3, select: 3]

  alias GymRats.Model.Challenge

  defdelegate now, to: NaiveDateTime, as: :utc_now

  def all(query \\ Challenge) do
    query 
    |> select([c], c)
  end

  def active(query \\ Challenge) do
    query
    |> where([c], c.start_date < ^now and c.end_date > ^now)
  end

  def complete(query \\ Challenge) do
    query
    |> where([c], c.end_date < ^now)
  end

  def upcoming(query \\ Challenge) do
    query
    |> where([c], c.start_date > ^now)
  end

  def exists?(query \\ Challenge, [code: code]) do
    query 
    |> where([c], c.code == ^code)
  end
end