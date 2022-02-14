defmodule BankAPI.Accounts.ProcessManagers.TransferMoney do
  use Commanded.ProcessManagers.ProcessManager,
    name: "Accounts.ProcessManagers.TransferMoney",
    application: BankAPI.Commanded,
    idle_timeout: Application.compile_env!(:bank_api, :process_manager_idle_timeout)

  @derive Jason.Encoder
  defstruct [
    :transfer_uuid,
    :source_account_uuid,
    :destination_account_uuid,
    :amount,
    :status
  ]

  alias __MODULE__
  alias BankAPI.Accounts.Commands.DepositIntoAccount
  alias BankAPI.Accounts.Commands.WithdrawFromAccount
  alias BankAPI.Accounts.Events.DepositedIntoAccount
  alias BankAPI.Accounts.Events.MoneyTransferRequested
  alias BankAPI.Accounts.Events.WithdrawnFromAccount

  def interested?(%MoneyTransferRequested{transfer_uuid: transfer_uuid}) do
    {:start!, transfer_uuid}
  end

  def interested?(%WithdrawnFromAccount{transfer_uuid: transfer_uuid})
      when is_nil(transfer_uuid),
      do: false

  def interested?(%WithdrawnFromAccount{transfer_uuid: transfer_uuid}),
    do: {:continue!, transfer_uuid}

  def interested?(%DepositedIntoAccount{transfer_uuid: transfer_uuid})
      when is_nil(transfer_uuid),
      do: false

  def interested?(%DepositedIntoAccount{transfer_uuid: transfer_uuid}),
    do: {:stop, transfer_uuid}

  def interested?(_event), do: false

  # handlers

  def handle(
        %TransferMoney{},
        %MoneyTransferRequested{
          source_account_uuid: source_account_uuid,
          amount: transfer_amount,
          transfer_uuid: transfer_uuid
        }
      ) do
    %WithdrawFromAccount{
      account_uuid: source_account_uuid,
      withdraw_amount: transfer_amount,
      transfer_uuid: transfer_uuid
    }
  end

  def handle(
        %TransferMoney{transfer_uuid: transfer_uuid} = pm,
        %WithdrawnFromAccount{transfer_uuid: transfer_uuid}
      ) do
    %DepositIntoAccount{
      account_uuid: pm.destination_account_uuid,
      deposit_amount: pm.amount,
      transfer_uuid: pm.transfer_uuid
    }
  end

  # state mutators

  def apply(%TransferMoney{} = pm, %MoneyTransferRequested{} = evt) do
    %TransferMoney{
      pm
      | transfer_uuid: evt.transfer_uuid,
        source_account_uuid: evt.source_account_uuid,
        destination_account_uuid: evt.destination_account_uuid,
        amount: evt.amount,
        status: :withdraw_money_from_source_account
    }
  end

  def apply(%TransferMoney{} = pm, %WithdrawnFromAccount{}) do
    %TransferMoney{
      pm
      | status: :deposit_money_in_destination_account
    }
  end
end
