defmodule BankAPI.Test.ProjectorUtils do
  alias BankAPI.Repo
  import Ecto.Query, only: [from: 2]

  def project(projector, event, projection_name) do
    :ok =
      projector.handle(event, %{
        event_number: next_event_number(projector, projection_name),
        handler_name: projection_name,
        created_at: DateTime.utc_now()
      })
  end

  def last_seen_event_number(projector, projection_name) do
    projector
    |> Module.concat(ProjectionVersion)
    |> BankAPI.Repo.get(projection_name)
    |> case do
      nil ->
        0

      projection_version ->
        Map.get(projection_version, :last_seen_event_number)
    end
  end

  def next_event_number(projector, projection_name),
    do: last_seen_event_number(projector, projection_name) + 1

  def truncate_database do
    truncate_readstore_tables_sql = """
    TRUNCATE TABLE
      accounts,
      projection_versions
    RESTART IDENTITY
    CASCADE;
    """

    {:ok, _result} = Repo.query(truncate_readstore_tables_sql)

    :ok
  end

  def get_last_seen_event_number(name) do
    from(
      p in "projection_versions",
      where: p.projection_name == ^name,
      select: p.last_seen_event_number
    )
    |> Repo.one() || 0
  end

  def only_instance_of(module) do
    module |> Repo.one()
  end
end
