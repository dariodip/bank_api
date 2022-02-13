defmodule BankAPI.Accounts.Projectors.AccountOpened do
  use Commanded.Projections.Ecto,
    application: BankAPI.Commanded,
    name: "Accounts.Projectors.AccountOpened",
    repo: BankAPI.Repo

  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Projections.Account

  project(%AccountOpened{} = evt, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :account_opened, %Account{
      uuid: evt.account_uuid,
      current_balance: evt.initial_balance,
      status: Account.status().open
    })
  end)
end
