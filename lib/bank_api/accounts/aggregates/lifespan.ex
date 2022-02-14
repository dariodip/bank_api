defmodule BankAPI.Accounts.Aggregates.Lifespan do
  @behaviour Commanded.Aggregates.AggregateLifespan

  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Events.DepositedIntoAccount
  alias BankAPI.Accounts.Events.AccountClosed

  def after_event(%DepositedIntoAccount{}), do: :timer.hours(1)
  def after_event(%AccountClosed{}), do: :stop
  def after_event(_event), do: :infinity

  def after_command(%CloseAccount{}), do: :stop
  def after_command(_command), do: :infinity

  def after_error(:invalid_initial_balance), do: :timer.minutes(5)
  def after_error(_error), do: :stop
end
