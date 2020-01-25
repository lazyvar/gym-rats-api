defmodule GymRatsWeb.Router do
  use GymRatsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GymRatsWeb do
    pipe_through :api

  end
