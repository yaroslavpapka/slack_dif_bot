defmodule SlackBot.Messenger do
  @channel "#name_tracker_channel"

  def send_message(text) do
    url = "https://slack.com/api/chat.postMessage"

    headers = [
      {"Authorization", "Bearer #{System.get_env("SLACK_BOT_TOKEN")}"},
      {"Content-Type", "application/json"}
    ]

    body =
      %{
        channel: @channel,
        text: text
      }
      |> Jason.encode!()

    request = Finch.build(:post, url, headers, body)

    case Finch.request(request, SlackFinch) do
      {:ok, %Finch.Response{status: 200, body: response_body}} ->
        Jason.decode(response_body)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
