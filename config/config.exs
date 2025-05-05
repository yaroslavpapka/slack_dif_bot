import Config

config :slack_bot, SlackBot.Scheduler,
  jobs: [
    {"43 11 * * 1", {SlackBot.DiffBot, :run, []}} #14-42 (-2.5)
  ]
