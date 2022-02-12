defmodule BankAPI.ProjectorCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias BankAPI.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import BankAPI.DataCase

      import BankAPI.Test.ProjectorUtils
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankAPI.Repo)

    :ok
  end
end
