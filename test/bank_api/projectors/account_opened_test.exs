defmodule BankAPI.Accounts.Projectors.AccountOpenedTest do
  use BankAPI.DataCase, async: false
  use ExUnit.Case, async: false
  import BankAPI.Test.ProjectorUtils

  alias BankAPI.Accounts.Projections.Account
  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Projectors.AccountOpened, as: Projector

  test "should succeed with valid data" do
    uuid = UUID.uuid4()

    account_opened_evt = %AccountOpened{
      account_uuid: uuid,
      initial_balance: 1_000
    }

    assert :ok = project(Projector, account_opened_evt, "account_opened")

    assert only_instance_of(Account).current_balance == 1_000
    assert only_instance_of(Account).uuid == uuid
  end
end
