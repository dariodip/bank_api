defmodule BankAPI.ProjectorsSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = Application.get_env(:bank_api, :projectors_supervisor_children, [])

    Supervisor.init(children, strategy: :one_for_one)
  end
end
