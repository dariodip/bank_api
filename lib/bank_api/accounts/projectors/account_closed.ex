defmodule BankAPI.Accounts.Projectors.AccountClosed do
  use Commanded.Projections.Ecto,
    application: BankAPI.Commanded,
    name: "Accounts.Projectors.AccountClosed",
    repo: BankAPI.Repo

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events.AccountClosed
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.Changeset
  alias Ecto.Multi

  project(%AccountClosed{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(account, status: Account.status().closed)
      )
    else
      _ -> multi
    end
  end)
end
