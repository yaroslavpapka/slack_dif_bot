defmodule SlackBot.DiffBot do
  alias SlackBot.Client
  alias SlackBot.MicrosoftClient
  alias SlackBot.Messenger

  def run do
    slack_users = Client.get_users()
    pf_users = MicrosoftClient.get_users()

    slack_map = Map.new(slack_users, &{&1.email, &1})
    pf_map = Map.new(pf_users, &{&1.email, &1})

    slack_emails = Map.keys(slack_map) |> MapSet.new()
    pf_emails = Map.keys(pf_map) |> MapSet.new()

    in_pf_not_in_slack = MapSet.difference(pf_emails, slack_emails)
    in_slack_not_in_pf = MapSet.difference(slack_emails, pf_emails)
    in_both = MapSet.intersection(slack_emails, pf_emails)

    messages = [
      "🔵 In Microsoft, but not in Slack:",
      format_user_list(in_pf_not_in_slack, pf_map),

      "\n🔵 In Slack, but not in Microsoft:",
      format_user_list(in_slack_not_in_pf, slack_map),

      "\n🔵 Present in both, but with different names:",
      format_name_mismatches(in_both, slack_map, pf_map)
    ]

    Messenger.send_message(Enum.join(messages, "\n"))
  end

  defp format_user_list(emails, map) do
    emails
    |> Enum.map(fn email ->
      user = map[email]
      "- #{user.name} <#{user.email}>"
    end)
    |> Enum.join("\n")
  end

  defp format_name_mismatches(emails, slack_map, pf_map) do
    emails
    |> Enum.filter(fn email ->
      slack_map[email].name != pf_map[email].name
    end)
    |> Enum.map(fn email ->
      """
      - Email: #{email}
        Slack: #{slack_map[email].name}
        Microsoft: #{pf_map[email].name}
      """
    end)
    |> Enum.join("\n")
  end
end
