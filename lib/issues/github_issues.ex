defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Tejas tejsbubane@gmail.com"} ]
  @github_url Application.get_env(:issues, :github_url)

  require Logger

  def fetch(user, project) do
    Logger.info "Fetching user #{user}'s project #{project}"
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Logger.info "Successful response"
    json = :jsx.decode(body)
    Logger.debug fn -> inspect(json) end
    { :ok, json }
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    Logger.error "Error 404 returned"
    { :error, "Given project was not found" }
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.error "Error occurred: #{reason}"
    { :error, reason }
  end
end
