defmodule GymRats.ProtectedController do
  defmacro __using__(_opts \\ []) do
    quote do
      def action(conn, _opts) do
        apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.account_id])
      end
    end
  end
end
