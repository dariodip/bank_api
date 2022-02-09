defmodule BankAPI.EventStore do
  use EventStore, otp_app: :bank_api

  def init(config) do
    {:ok, config}
  end
end
