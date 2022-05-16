defmodule CharmerTest do
  use ExUnit.Case
  doctest Charmer

  @python_path "test"
  @python_test_module "test"

  test "singe call" do
    Charmer.start_link(python_path: @python_path)
    result = Charmer.call(@python_test_module, "inc", [1])
    Charmer.stop()
    assert result == 2
  end

  test "single async call" do
    Charmer.start_link(python_path: @python_path)

    result =
      Task.async(fn -> Charmer.call(@python_test_module, "inc", [1]) end)
      |> Task.await()

    Charmer.stop()
    assert result == 2
  end

  test "async map on pool" do
    Charmer.start_link(python_path: @python_path, pool_size: 3)

    result =
      1..10
      |> Task.async_stream(&Charmer.call(@python_test_module, "inc", [&1]))
      |> Enum.map(fn {:ok, x} -> x end)

    Charmer.stop()
    assert result == 2..11 |> Enum.to_list()
  end

  test "python doc string" do
    Charmer.start_link(python_path: @python_path)

    result = Charmer.call(@python_test_module, "inc.__doc__.__str__", [])

    Charmer.stop()
    assert result == "Add 1 to the given number." |> String.to_char_list()
  end

  test "show data" do
    Charmer.start_link(python_path: @python_path)

    result =
      Charmer.call(@python_test_module, "show", [
        %{"a" => 1, "b" => "thing", "c" => ~D[2020-12-16]}
      ])

    Charmer.stop()
    assert result == %{"a" => 1, "b" => "thing", "c" => ~D[2020-12-16]}
  end
end
