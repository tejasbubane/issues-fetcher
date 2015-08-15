defmodule CliTest do
  use ExUnit.Case

  import Issues.CLI, only: [ parse_args: 1,
                             sort_ascending: 1 ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "99"]) == { "user", "project", 99 }
  end

  test "count is defaulted if two values given" do
    assert parse_args(["user", "project"]) == { "user", "project", 4 }
  end

  test "sort ascending orders the correct way" do
    result = sort_ascending(fake_created_at_list(~w{a b c}))
    issues = for issue <- result, do: issue[ "created_at" ]
    assert issues == ~w{a b c}
  end

  defp fake_created_at_list(values) do
    for value <- values, do: %{"created_at" => value,
                               "other_data" => "some_data"}
  end
end
