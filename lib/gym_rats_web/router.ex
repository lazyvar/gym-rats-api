defmodule GymRatsWeb.Router do
  use GymRatsWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug GymRats.Guardian
  end

  scope "/", GymRatsWeb do
    pipe_through [:api, :protected]

    get "/account", AccountController, :show
    put "/account", AccountController, :update

    # deprecated do

    put "/accounts/self", AccountController, :update

    # end

    resources "/accounts", AccountController, only: [] do
      resources "/workouts", Account.WorkoutController, only: [:index]
    end

    resources "/challenges", ChallengeController, only: [:create, :index, :update, :show] do
      get "/chat_notifications/count", Challenge.ChatNotificationController, :count
      post "/chat_notifications/seen", Challenge.ChatNotificationController, :seen
      get "/group_stats", Challenge.GroupStatsController, :group_stats
      get "/info", Challenge.InfoController, :info

      resources "/members", Challenge.MemberController, only: [:index] do
        resources "/workouts", Challenge.Member.WorkoutController, only: [:index]
      end

      resources "/messages", Challenge.MessageController, only: [:index]
      resources "/rankings", Challenge.RankingController, only: [:index]
      resources "/team_rankings", Challenge.TeamRankingController, only: [:index]
      resources "/teams", Challenge.TeamController, only: [:index]
      resources "/workouts", Challenge.WorkoutController, only: [:index]
    end

    resources "/comments", CommentController, only: [:delete]
    resources "/devices", DeviceController, only: [:create]
    delete "/devices", DeviceController, :delete_all
    resources "/memberships", MembershipController, only: [:create, :delete, :show]
    resources "/team_memberships", TeamMembershipController, only: [:create, :delete]
    resources "/teams", TeamController, only: [:create, :update]

    resources "/workouts", WorkoutController, only: [:create, :delete, :show, :update] do
      resources "/comments", Workout.CommentController, only: [:create, :index]
    end
  end

  scope "/", GymRatsWeb do
    pipe_through :api

    resources "/accounts", Open.AccountController, only: [:create]
    resources "/passwords", Open.PasswordController, only: [:update, :create]
    resources "/tokens", Open.TokenController, only: [:create]
  end

  scope "/", GymRatsWeb do
    get "/unsubscribe", EmailController, :unsubscribe
    get "/subscribe", EmailController, :subscribe
  end

  if Application.get_env(:gym_rats, :environment) == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
