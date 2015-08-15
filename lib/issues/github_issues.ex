defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Tejas tejsbubane@gmail.com"} ]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    { :ok, body }
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    { :error, "Given project was not found" }
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    { :error, reason }
  end
end
