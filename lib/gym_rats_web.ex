defmodule GymRatsWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: GymRatsWeb

      import Plug.Conn
      import GymRatsWeb.Gettext
      import GymRatsWeb.Rendering

      alias GymRatsWeb.Router.Helpers, as: Routes
      alias GymRats.Repo
    end
  end

  def protected_controller do
    quote do
      use GymRatsWeb, :controller
      use GymRats.ProtectedController
    end
  end

  def view do
    quote do
      use Phoenix.HTML
      use Phoenix.View,
        root: "lib/gym_rats_web/templates",
        namespace: GymRatsWeb

      import GymRatsWeb.ErrorHelpers
      import GymRatsWeb.Gettext
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      alias GymRatsWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      import GymRatsWeb.Gettext
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
