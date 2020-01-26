defmodule GymRatsWeb.Router do
  use GymRatsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", GymRatsWeb, as: :auth do
    pipe_through :api

    resources "/tokens", Auth.TokenController, only: [:create]
    resources "/accounts", Auth.AccountController, only: [:create]
    resources "/passwords", Auth.PasswordController, only: [:update, :create]
  end

  scope "/", GymRatsWeb do
    pipe_through :api

    resources "/accounts", AccountController, only: [:update] do
      resources "/workouts", Account.WorkoutController, only: [:index]
    end
    resources "/memberships", MembershipController, param: "challenge_id", only: [:create, :delete]
    resources "/challenges", ChallengeController, only: [:create, :index, :update] do
      resources "/workouts", Challenge.WorkoutController, only: [:index]
      resources "/members", Challenge.MemberController, only: [:index] do
        resources "/workouts", Challenge.Member.WorkoutsController, only: [:index]
      end
      resources "/messages", Challenge.MessageController, only: [:index]
    end
    resources "/workouts", WorkoutController, only: [:create, :delete] do
      resources "/comments", Workout.CommentController, only: [:create, :index]
    end
    resources "/comments", CommentController, only: [:delete]
    resources "/messages", MessageController, only: [:create]
    resources "/devices", DeviceController, only: [:create, :delete]
  end
end
