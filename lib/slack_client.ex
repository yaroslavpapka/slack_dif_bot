defmodule SlackBot.Client do
  @moduledoc false

  @default_url "https://slack.com/api/users.list"

  def get_users(token \\ System.get_env("SLACK_BOT_TOKEN"), finch \\ SlackFinch) do
    stream_users(token, finch)
    |> Enum.flat_map(& &1)
    |> Enum.filter(&real_user?/1)
    |> Enum.map(&extract_user/1)
    |> Enum.reject(&is_nil/1)
  end

  defp stream_users(token, finch) do
    Stream.unfold(nil, fn
      nil -> fetch_page(nil, token, finch)
      cursor when cursor != "" -> fetch_page(cursor, token, finch)
      _ -> nil
    end)
  end

  defp fetch_page(cursor, token, finch) do
    url = build_url(cursor)
    headers = build_headers(token)

    with {:ok, %Finch.Response{status: 200, body: body}} <-
           Finch.build(:get, url, headers) |> Finch.request(finch),
         {:ok, decoded} <- Jason.decode(body),
         %{"ok" => true, "members" => members} = data <- decoded do
      next_cursor = get_in(data, ["response_metadata", "next_cursor"]) || ""
      {members, next_cursor}
    else
      _ -> nil
    end
  end

  defp build_url(nil), do: "#{@default_url}?limit=200"
  defp build_url(cursor), do: "#{@default_url}?limit=200&cursor=#{cursor}"

  defp build_headers(token) do
    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]
  end

  defp real_user?(user) do
    not Map.get(user, "deleted", false) and
      not Map.get(user, "is_bot", false) and
      Map.get(user, "id") != "USLACKBOT"
  end

  defp extract_user(%{
         "profile" =>
           %{
             "email" => email
           } = profile
       })
       when is_binary(email) do
    name =
      profile
      |> Map.get("real_name", "")
      |> String.trim()
      |> case do
        "" -> "Not found"
        real_name -> clean_name(real_name)
      end

    %{
      name: name,
      email: String.downcase(email)
    }
  end

  defp extract_user(_), do: nil

  defp clean_name(name) do
    name
    |> String.replace(~r/'[^']*'/, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
