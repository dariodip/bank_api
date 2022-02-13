defmodule BankAPI.Accounts.Commands.Validators do
  def positive_integer(data) do
    cond do
      is_integer(data) ->
        if data > 0 do
          :ok
        else
          {:error, "Argument must be bigger than 0"}
        end

      true ->
        {:error, "Argument must be an integer"}
    end
  end
end
