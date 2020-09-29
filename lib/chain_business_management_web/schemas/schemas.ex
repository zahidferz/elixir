defmodule ChainBusinessManagementWeb.Schemas do
  @moduledoc false

  @spec validate_schema(atom, map) :: {:bad_request, Ecto.Changeset} | {:ok, map()}
  def validate_schema(module, params) do
    changeset = module.changeset(params)

    case changeset.valid? do
      true ->
        {:ok, changeset.changes}

      _ ->
        {:bad_request, changeset}
    end
  end

  @doc """
  Given a module and a list of entries validates with the module.changeset
  """
  @spec validate_schemas(atom, list(any)) :: {:ok, list()} | {:bad_request, Ecto.Changeset}
  def validate_schemas(module, entries) do
    entries
    |> validate_schemas(module, [])
  end

  defp validate_schemas([], _module, acc), do: {:ok, acc}
  defp validate_schemas(:error, _module, error_response), do: error_response

  defp validate_schemas([params | tail], module, acc) do
    case validate_schema(module, params) do
      {:ok, changes} ->
        validate_schemas(tail, module, [changes | acc])

      error_response ->
        validate_schemas(:error, module, error_response)
    end
  end
end
