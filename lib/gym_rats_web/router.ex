defmodule GymRatsWeb.Router do
  use GymRatsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug GymRats.Guardian
  end

  scope "/", GymRatsWeb do
    pipe_through [:api, :protected]

    resources "/accounts", AccountController, only: [:update]
    resources "/challenges", ChallengeController, only: [:create, :index, :update] do
      resources "/members", Challenge.MemberController, only: [:index]
      resources "/messages", Challenge.MessageController, only: [:index]
      resources "/workouts", Challenge.WorkoutController, only: [:index]
    end
    resources "/comments", CommentController, only: [:delete]
    resources "/devices", DeviceController, only: [:create, :delete] do
      resources "/workouts", Account.WorkoutController, only: [:index]
    end
    resources "/memberships", MembershipController, only: [:create, :delete]
    resources "/messages", MessageController, only: [:create]
    resources "/workouts", WorkoutController, only: [:create, :delete] do
      resources "/comments", Workout.CommentController, only: [:create, :index]
    end
  end

  scope "/", GymRatsWeb do
    pipe_through :api

    resources "/accounts", Open.AccountController, only: [:create]
    resources "/passwords", Open.PasswordController, only: [:update, :create]
    resources "/tokens", Open.TokenController, only: [:create]
  end
end
