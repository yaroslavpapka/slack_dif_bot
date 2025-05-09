# 🤖 SlackBot DiffBot

Elixir application that compares users between **Slack** and **Microsoft** systems, highlighting discrepancies in user presence and name mismatches. It uses the Slack Web API and Microsoft Graph API, with results sent as a summary message.

---

## ✨ Features

- Fetches users from both Slack and Microsoft
- Detects users present in one system but not the other
- Finds users present in both systems but with different names
- Sends a formatted report via the `Messenger` module

---

## 🧱 Project Structure

- `SlackBot.Client` – Fetches real users from Slack using Slack API
- `SlackBot.MicrosoftClient` – Retrieves users from Microsoft (implementation assumed)
- `SlackBot.Messenger` – Sends comparison results (e.g. to Slack or elsewhere)
- `SlackBot.DiffBot` – The main logic for comparing users and formatting the output

---

## 🚀 How to Run

1. **Install dependencies**:

    ```bash
    mix deps.get
    ```

2. **Set environment variables**:

    Option 1: Using a `.env` file (recommended)

    ```
    MICROSOFT_TENANT_ID=""
    MICROSOFT_CLIENT_ID=""
    MICROSOFT_CLIENT_SECRET=""
    SLACK_BOT_TOKEN=""
    ```

    Option 2: Using `export` command in the terminal

    ```bash
    export MICROSOFT_TENANT_ID=""     
    export MICROSOFT_CLIENT_ID="..."   
    export MICROSOFT_CLIENT_SECRET="..."   
    export SLACK_BOT_TOKEN="..."   
    ```

3. **Start the application**:

    ```bash
    iex -S mix
    ```

4. **Run the comparison task**:

    ```elixir
    SlackBot.DiffBot.run()
    ```

---

## 🧪 Example Output

🔵 In Microsoft, but not in Slack:

    Jane Doe jane.doe@example.com

🔵 In Slack, but not in Microsoft:

    John Smith john.smith@example.com

🔵 Present in both, but with different names:

    Email: alex@example.com
    Slack: Alexey Petrov
    Microsoft: Alexander Petrov
