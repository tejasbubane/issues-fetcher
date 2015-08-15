defmodule Issues.CLI do

  @default_count 4

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

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

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_ascending
    |> Enum.take(count)
  end

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
