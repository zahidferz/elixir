defmodule ChainBusinessManagement.BanksTest do
  use ChainBusinessManagement.DataCase

  alias ChainBusinessManagement.Banks

  describe "banks_catalog" do
    alias ChainBusinessManagement.Banks.BanksCatalog

    @valid_attrs %{enabled: true, logo: "some logo", name: "some name", code: "000"}
    @update_attrs %{
      enabled: false,
      logo: "some updated logo",
      name: "some updated name",
      code: "001"
    }
    @invalid_attrs %{enabled: nil, logo: nil, name: nil}

    def banks_catalog_fixture_local(attrs \\ %{}) do
      {:ok, banks_catalog} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Banks.create_banks_catalog()

      banks_catalog
    end

    # @tag :skip
    test "list_banks_catalog/0 returns all banks_catalog" do
      banks_catalog = Banks.list_banks_catalog()
      assert Enum.count(banks_catalog) == 93
    end

    test "get_banks_catalog!/1 returns the banks_catalog with given id" do
      banks_catalog = banks_catalog_fixture_local()
      assert Banks.get_banks_catalog!(banks_catalog.id) == banks_catalog
    end

    test "create_banks_catalog/1 with valid data creates a banks_catalog" do
      assert {:ok, %BanksCatalog{} = banks_catalog} = Banks.create_banks_catalog(@valid_attrs)
      assert banks_catalog.enabled == true
      assert banks_catalog.logo == "some logo"
      assert banks_catalog.name == "some name"
    end

    test "create_banks_catalog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Banks.create_banks_catalog(@invalid_attrs)
    end

    test "update_banks_catalog/2 with valid data updates the banks_catalog" do
      banks_catalog = banks_catalog_fixture_local()

      assert {:ok, %BanksCatalog{} = banks_catalog} =
               Banks.update_banks_catalog(banks_catalog, @update_attrs)

      assert banks_catalog.enabled == false
      assert banks_catalog.logo == "some updated logo"
      assert banks_catalog.name == "some updated name"
    end

    test "update_banks_catalog/2 with invalid data returns error changeset" do
      banks_catalog = banks_catalog_fixture_local()

      assert {:error, %Ecto.Changeset{}} =
               Banks.update_banks_catalog(banks_catalog, @invalid_attrs)

      assert banks_catalog == Banks.get_banks_catalog!(banks_catalog.id)
    end

    test "delete_banks_catalog/1 deletes the banks_catalog" do
      banks_catalog = banks_catalog_fixture_local()
      assert {:ok, %BanksCatalog{}} = Banks.delete_banks_catalog(banks_catalog)
      assert_raise Ecto.NoResultsError, fn -> Banks.get_banks_catalog!(banks_catalog.id) end
    end

    test "change_banks_catalog/1 returns a banks_catalog changeset" do
      banks_catalog = banks_catalog_fixture_local()
      assert %Ecto.Changeset{} = Banks.change_banks_catalog(banks_catalog)
    end

    test "get_bank_code/1 returns error tuple with non existant bank" do
      assert {:error, "code_not_associated_with_bank"} = Banks.get_bank_by_code("0")
    end

    test "get_bank_code/1 returns a bank for the given code" do
      bank_catalog = banks_catalog_fixture(%{code: "00000001"})
      {:ok, bank_founded} = Banks.get_bank_by_code("00000001")

      assert bank_founded == bank_catalog
    end
  end
end
