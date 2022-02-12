ExUnit.configure(exclude: [:pending, :acceptance])

ExUnit.start(capture_log: true)
Ecto.Adapters.SQL.Sandbox.mode(BankAPI.Repo, :manual)
