defmodule BankAPI.Commanded do
  use Commanded.Application,
    otp_app: :bank_api

  router(BankAPI.Router)

  def init(config) do
    {:ok, config}
  end
end
