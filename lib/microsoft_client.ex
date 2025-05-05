defmodule SlackBot.MicrosoftClient do
  @moduledoc false

  def get_users do
    with {:ok, token} <- fetch_access_token(),
         {:ok, users} <- fetch_users(token) do
      users
    else
      error ->
        IO.inspect(error, label: "Failed to fetch users")
        []
    end
  end

  defp fetch_access_token do
    tenant_id = System.get_env("MICROSOFT_TENANT_ID")
    client_id = System.get_env("MICROSOFT_CLIENT_ID")
    client_secret = System.get_env("MICROSOFT_CLIENT_SECRET")
    scope = "https://graph.microsoft.com/.default"

    url = "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token"

    body = URI.encode_query(%{
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "client_credentials",
      scope: scope
    })

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    request = Finch.build(:post, url, headers, body)

    case Finch.request(request, SlackFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"access_token" => token}} -> {:ok, token}
          _ -> {:error, :invalid_token_response}
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_users(token) do
    fetch_users_paginated("https://graph.microsoft.com/v1.0/users", token, [])
  end

  defp fetch_users_paginated(url, token, acc) do
    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]

    request = Finch.build(:get, url, headers)

    case Finch.request(request, SlackFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"value" => users, "@odata.nextLink" => next_link}} ->
            mapped =
              Enum.map(users, fn user ->
                %{
                  name: user["displayName"],
                  email: (user["mail"] || user["userPrincipalName"]) |> String.downcase()
                }
              end)

            fetch_users_paginated(next_link, token, acc ++ mapped)

          {:ok, %{"value" => users}} ->
            mapped =
              Enum.map(users, fn user ->
                %{
                  name: user["displayName"],
                  email: user["mail"] || user["userPrincipalName"]
                }
              end)

            {:ok, acc ++ mapped}

          _ ->
            {:error, :invalid_users_response}
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
