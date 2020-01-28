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
      resources "/members", Challenge.MemberController, only: [:index] do
        resources "/workouts", Challenge.Member.WorkoutsController, only: [:index]
      end
      resources "/messages", Challenge.MessageController, only: [:index]
      resources "/workouts", Challenge.WorkoutController, only: [:index]
    end
    resources "/comments", CommentController, only: [:delete]
    resources "/devices", DeviceController, only: [:create, :delete] do
      resources "/workouts", Account.WorkoutController, only: [:index]
    end
    resources "/memberships", MembershipController, param: "challenge_id", only: [:create, :delete]
    resources "/messages", MessageController, only: [:create]
    resources "/workouts", WorkoutController, only: [:create, :delete] do
      resources "/comments", Workout.CommentController, only: [:create, :index]
    end
  end

  scope "/", GymRatsWeb do
    pipe_through :api

    resources "/accounts", AccountController, only: [:create]
    resources "/passwords", PasswordController, only: [:update, :create]
    resources "/tokens", TokenController, only: [:create]
  end
end
