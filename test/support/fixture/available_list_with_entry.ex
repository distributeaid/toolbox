defmodule Ferry.Fixture.AvailableListWithEntry do
  import Ferry.ApiClient.{Address, Group, AvailableList, Category, Item, AvailableListEntry}

  def setup(%{conn: conn} = context) do
    %{
      "data" => %{
        "createGroup" => %{
          "successful" => true,
          "result" => %{
            "id" => group
          }
        }
      }
    } = create_simple_group(conn, %{name: "a group"})

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => address
          }
        }
      }
    } = create_address(conn, %{group: group, label: "test"})

    %{
      "data" => %{
        "createAvailableList" => %{
          "successful" => true,
          "result" => %{
            "id" => available_list
          }
        }
      }
    } =
      create_available_list(conn, %{
        address: address
      })

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "clothes"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => item
          }
        }
      }
    } =
      create_item(conn, %{
        category: category,
        name: "tshirt"
      })

    %{
      "data" => %{
        "createAvailableListEntry" => %{
          "successful" => true,
          "result" => %{
            "id" => entry
          }
        }
      }
    } =
      create_available_list_entry(conn, %{
        list: available_list,
        item: item,
        amount: 1
      })

    {:ok,
     Map.merge(context, %{
       address: address,
       available: available_list,
       item: item,
       entry: entry
     })}
  end
end
