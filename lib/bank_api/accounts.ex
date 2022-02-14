defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias BankAPI.Repo
  alias BankAPI.Commanded
  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Commands.DepositIntoAccount
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Commands.WithdrawFromAccount
  alias BankAPI.Accounts.Commands.TransferBetweenAccounts
  alias BankAPI.Accounts.Projections.Account

  @doc """
  get account reads an account from the read model
  """
  def get_account(uuid) do
    case Repo.get(Account, uuid) do
      %Account{} = account ->
        {:ok, account}

      _reply ->
        {:error, :not_found}
    end
  end

  @doc """
  open account sends the command OpenAccount
  and returns an account if everything goes ok
  """
  def open_account(%{"initial_balance" => initial_balance}) do
    account_uuid = UUID.uuid4()

    dispatch_result =
      %OpenAccount{
        initial_balance: initial_balance,
        account_uuid: account_uuid
      }
      |> Commanded.dispatch()

    case dispatch_result do
      :ok ->
        {
          :ok,
          %Account{
            uuid: account_uuid,
            current_balance: initial_balance,
            status: Account.status().open
          }
        }

      reply ->
        reply
    end
  end

  def open_account(_params), do: {:error, :bad_command}

  @doc """
  close account sends a close account command
  """
  def close_account(id) do
    %CloseAccount{
      account_uuid: id
    }
    |> Commanded.dispatch()
  end

  def deposit(id, amount) do
    dispatch_result =
      %DepositIntoAccount{
        account_uuid: id,
        deposit_amount: amount
      }
      |> Commanded.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          Repo.get!(Account, id)
        }

      reply ->
        reply
    end
  end

  def withdraw(id, amount) do
    dispatch_result =
      %WithdrawFromAccount{
        account_uuid: id,
        withdraw_amount: amount
      }
      |> Commanded.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          Repo.get!(Account, id)
        }

      reply ->
        reply
    end
  end

  def transfer(source_id, amount, destination_id) do
    %TransferBetweenAccounts{
      account_uuid: source_id,
      transfer_uuid: UUID.uuid4(),
      transfer_amount: amount,
      destination_account_uuid: destination_id
    }
    |> Commanded.dispatch()
  end

  def uuid_regex do
    ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
  end
end
