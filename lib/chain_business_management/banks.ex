defmodule ChainBusinessManagement.Banks do
  @moduledoc """
  This module contains the operations to interact with the bank accounts.
  """

  import Ecto.Query, warn: false
  alias ChainBusinessManagement.Repo

  alias ChainBusinessManagement.Banks.BanksCatalog

  @doc """
  Returns the list of banks_catalog.

  ## Examples

      iex> list_banks_catalog()
      [%BanksCatalog{}, ...]

  """
  @spec list_banks_catalog() :: list(BanksCatalog.t())
  def list_banks_catalog do
    Repo.all(BanksCatalog)
  end

  @doc """
  Gets a single banks_catalog.

  Raises `Ecto.NoResultsError` if the Banks catalog does not exist.

  ## Examples

      iex> get_banks_catalog!(123)
      %BanksCatalog{}

      iex> get_banks_catalog!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_banks_catalog!(pos_integer) :: BanksCatalog.t() | any
  def get_banks_catalog!(id), do: Repo.get!(BanksCatalog, id)

  @doc """
  Creates a banks_catalog.

  ## Examples

      iex> create_banks_catalog(%{field: value})
      {:ok, %BanksCatalog{}}

      iex> create_banks_catalog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_banks_catalog(map()) :: {:ok, BanksCatalog.t()} | {:error, Ecto.Changeset.t()}
  def create_banks_catalog(attrs \\ %{}) do
    %BanksCatalog{}
    |> BanksCatalog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a banks_catalog.

  ## Examples

      iex> update_banks_catalog(banks_catalog, %{field: new_value})
      {:ok, %BanksCatalog{}}

      iex> update_banks_catalog(banks_catalog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_banks_catalog(BanksCatalog.t(), map()) ::
          {:ok, BanksCatalog.t()} | {:error, Ecto.Changeset.t()}
  def update_banks_catalog(%BanksCatalog{} = banks_catalog, attrs) do
    banks_catalog
    |> BanksCatalog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a banks_catalog.

  ## Examples

      iex> delete_banks_catalog(banks_catalog)
      {:ok, %BanksCatalog{}}

      iex> delete_banks_catalog(banks_catalog)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_banks_catalog(BanksCatalog.t()) ::
          {:ok, BanksCatalog.t()} | {:error, Ecto.Changeset.t()}
  def delete_banks_catalog(%BanksCatalog{} = banks_catalog) do
    Repo.delete(banks_catalog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking banks_catalog changes.

  ## Examples

      iex> change_banks_catalog(banks_catalog)
      %Ecto.Changeset{data: %BanksCatalog{}}

  """
  @spec change_banks_catalog(BanksCatalog.t(), map) :: Ecto.Changeset.t()
  def change_banks_catalog(%BanksCatalog{} = banks_catalog, attrs \\ %{}) do
    BanksCatalog.changeset(banks_catalog, attrs)
  end

  @doc """
  Returns a bank for the given code

  ## Examples

      iex> get_bank_by_code("002")
      {:ok, %BanksCatalog{}}

      iex> get_bank_by_code("000")
      {:error, "code not associated with bank"}
  """
  @spec get_bank_by_code(String.t()) :: {:ok, BanksCatalog.t()} | {:error, String.t()}
  def get_bank_by_code(code) when is_binary(code) do
    BanksCatalog
    |> Repo.get_by(code: code)
    |> case do
      nil -> {:error, "code_not_associated_with_bank"}
      bank -> {:ok, bank}
    end
  end
end
