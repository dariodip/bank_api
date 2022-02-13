defmodule BankAPI.Repo.Migrations.AddStatusToAccount do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:status, :text)
    end
  end
end
