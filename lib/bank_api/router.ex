defmodule BankAPI.Router do
  use Commanded.Commands.Router

  alias BankAPI.Accounts.Aggregates.Account
  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Commands.DepositIntoAccount
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Commands.WithdrawFromAccount

  middleware(BankAPI.Middleware.ValidateCommand)

  dispatch([OpenAccount, CloseAccount, DepositIntoAccount, WithdrawFromAccount],
    to: Account,
    identity: :account_uuid
  )
end
