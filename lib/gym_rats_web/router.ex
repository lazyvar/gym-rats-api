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

    put "/accounts/self", AccountController, :update_self
    resources "/accounts", AccountController, only: [] do
      resources "/workouts", Account.WorkoutController, only: [:index]
    end
    resources "/challenges", ChallengeController, only: [:create, :index, :update] do
      resources "/members", Challenge.MemberController, only: [:index] do
        resources "/workouts", Challenge.Member.WorkoutController, only: [:index]
      end
      resources "/messages", Challenge.MessageController, only: [:index]
    end
    resources "/comments", CommentController, only: [:delete]
    resources "/devices", DeviceController, only: [:create]
    delete "/devices", DeviceController, :delete_all
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
