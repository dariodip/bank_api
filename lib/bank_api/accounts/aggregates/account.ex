defmodule BankAPI.Accounts.Aggregates.Account do
  defstruct uuid: nil,
            current_balance: nil,
            closed?: false

  alias __MODULE__
  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Events.AccountClosed
  alias BankAPI.Accounts.Events.AccountOpened

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
        %Account{} = account,
        %AccountClosed{
          account_uuid: account_uuid
        }
      ) do
    %Account{
      account
      | closed?: true
    }
  end
end
