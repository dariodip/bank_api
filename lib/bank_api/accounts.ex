defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias BankAPI.Repo
  alias BankAPI.Commanded
  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Commands.OpenAccount
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
    |> Router.dispatch()
  end

  def uuid_regex do
    ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
  end

  defp account_opening_changeset(params) do
    {
      params,
      %{initial_balance: :integer}
    }
    |> Changeset.cast(params, [:initial_balance])
    |> Changeset.validate_required([:initial_balance])
    |> Changeset.validate_number(:initial_balance, greater_than: 0)
  end
end
