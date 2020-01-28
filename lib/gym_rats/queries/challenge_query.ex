defmodule GymRats.Query.ChallengeQuery do
  import Ecto.Query, only: [where: 3, select: 3]

  alias GymRats.Model.Challenge

  defdelegate now, to: NaiveDateTime, as: :utc_now

  def all do
    Challenge 
    |> select([c], c)
  end

  def active do
    Challenge
    |> where([c], c.start_date < ^now and c.end_date > ^now)
  end

  def complete do
    Challenge
    |> where([c], c.end_date < ^now)
  end

  def upcoming do
    Challenge
    |> where([c], c.start_date > ^now)
  end

  def exists?([code: code]) do
    Challenge 
    |> where([c], c.code == ^code)
  end
end