defmodule BankAPI.Accounts.Aggregates.Account do
  @derive Jason.Encoder
  defstruct uuid: nil,
            current_balance: nil,
            closed?: false

  alias __MODULE__
  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Commands.DepositIntoAccount
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Commands.WithdrawFromAccount
  alias BankAPI.Accounts.Commands.TransferBetweenAccounts
  alias BankAPI.Accounts.Events.AccountClosed
  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Events.DepositedIntoAccount
  alias BankAPI.Accounts.Events.WithdrawnFromAccount
  alias BankAPI.Accounts.Events.MoneyTransferRequested

  # matches an aggregate with no uuid (an account not yet opened)
  def execute(
        %Account{uuid: nil},
        %OpenAccount{
          account_uuid: account_uuid,
          initial_balance: initial_balance
        }
      )
      when initial_balance > 0 do
    %AccountOpened{
      account_uuid: account_uuid,
      initial_balance: initial_balance
    }
  end

  def execute(
        %Account{uuid: nil},
        %OpenAccount{
          initial_balance: initial_balance
        }
      )
      when initial_balance <= 0 do
    {:error, :initial_balance_must_be_above_zero}
  end

  def execute(%Account{}, %OpenAccount{}), do: {:error, :account_already_opened}

  def execute(%Account{uuid: account_uuid, closed?: true}, %CloseAccount{
        account_uuid: account_uuid
      }) do
    {:error, :account_already_closed}
  end

  def execute(%Account{uuid: account_uuid, closed?: false}, %CloseAccount{
        account_uuid: account_uuid
      }) do
    %AccountClosed{
      account_uuid: account_uuid
    }
  end

  def execute(%Account{}, %CloseAccount{}) do
    {:error, :not_found}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false, current_balance: current_balance},
        %DepositIntoAccount{account_uuid: account_uuid, deposit_amount: deposit_amount}
      ) do
    %DepositedIntoAccount{
      account_uuid: account_uuid,
      new_current_balance: current_balance + deposit_amount
    }
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %DepositIntoAccount{account_uuid: account_uuid}
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{},
        %DepositIntoAccount{}
      ) do
    {:error, :not_found}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false, current_balance: current_balance},
        %WithdrawFromAccount{account_uuid: account_uuid, withdraw_amount: withdraw_amount}
      ) do
    if current_balance - withdraw_amount > 0 do
      %WithdrawnFromAccount{
        account_uuid: account_uuid,
        new_current_balance: current_balance - withdraw_amount
      }
    else
      {:error, :insufficient_funds}
    end
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %WithdrawFromAccount{account_uuid: account_uuid}
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{},
        %WithdrawFromAccount{}
      ) do
    {:error, :not_found}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: true
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid
        }
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid,
          destination_account_uuid: destination_account_uuid
        }
      )
      when account_uuid == destination_account_uuid do
    {:error, :transfer_to_same_account}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false,
          current_balance: current_balance
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid,
          transfer_amount: transfer_amount
        }
      )
      when current_balance < transfer_amount do
    {:error, :insufficient_funds}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid,
          transfer_uuid: transfer_uuid,
          transfer_amount: transfer_amount,
          destination_account_uuid: destination_account_uuid
        }
      ) do
    %MoneyTransferRequested{
      transfer_uuid: transfer_uuid,
      source_account_uuid: account_uuid,
      amount: transfer_amount,
      destination_account_uuid: destination_account_uuid
    }
  end

  def execute(
        %Account{},
        %TransferBetweenAccounts{}
      ) do
    {:error, :not_found}
  end

  # state mutators

  # applies the event to change the aggregate's internal state
  def apply(
        %Account{} = account,
        %AccountOpened{
          account_uuid: account_uuid,
          initial_balance: initial_balkance
        }
      ) do
    %Account{
      account
      | uuid: account_uuid,
        current_balance: initial_balkance
    }
  end

  def apply(
        %Account{uuid: account_uuid} = account,
        %AccountClosed{
          account_uuid: account_uuid
        }
      ) do
    %Account{
      account
      | closed?: true
    }
  end

  def apply(
        %Account{
          uuid: account_uuid,
          current_balance: _current_balance
        } = account,
        %DepositedIntoAccount{
          account_uuid: account_uuid,
          new_current_balance: new_current_balance
        }
      ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
        %Account{
          uuid: account_uuid,
          current_balance: _current_balance
        } = account,
        %WithdrawnFromAccount{
          account_uuid: account_uuid,
          new_current_balance: new_current_balance
        }
      ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
        %Account{} = account,
        %MoneyTransferRequested{}
      ) do
    account
  end
end
