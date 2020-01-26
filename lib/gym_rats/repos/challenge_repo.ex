defmodule GymRats.Repo.ChallengeRepo do
  import Ecto.Query, only: [where: 3]

  alias GymRats.Repo
  alias GymRats.Model.Challenge

  defdelegate now, to: NaiveDateTime, as: :utc_now

  def all do
    Challenge |> Repo.all
  end

  def active do
    Challenge
    |> where([c], c.start_date < ^now and c.end_date > ^now)
    |> Repo.all
  end

  def complete do
    Challenge
    |> where([c], c.end_date < ^now)
    |> Repo.all
  end

  def upcoming do
    Challenge
    |> where([c], c.start_date > ^now)
    |> Repo.all
  end

  def exists?([code: code]) do
    Challenge 
    |> where([c], c.code == ^code) 
    |> Repo.exists?
  end
end