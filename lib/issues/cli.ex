defmodule Issues.CLI do

  @default_count 4

  @doc """
  This is the main function which is called from the binary executable.
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  Parse the command line arguments. Returns a tuple containing user, project
  and number of issues requested.
  ## Example
      iex> parse_args(["tejasbubane", "issues-fetcher", "3"])
      {"tejasbubane", "issues-fetcher", 3}

  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                     aliases:  [ h:    :help    ])
    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [ user, project, count], _ } -> { user, project,
                                             String.to_integer(count) }
      { _, [ user, project ], _ } -> { user, project, @default_count }
      _ -> :help
    end
  end

  @doc """
  Process the help request.
  """
  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  @doc """
  Process the user, project and count request.
  """
  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_ascending
    |> Enum.take(count)
    |> Issues.TableFormatter.print_table_for_columns(["number", "created_at", "title"])
  end

  @doc """
  Sort the issues by ascending order of `created_at`.
  """
  def sort_ascending(github_issues) do
    github_issues
    |> Enum.sort fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
  end

  defp decode_response({:ok, body}), do: body
  defp decode_response({:error, reason}) do
    IO.puts "Error fetching from Github: #{reason}"
    System.halt(2)
  end
end
