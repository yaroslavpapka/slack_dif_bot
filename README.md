# SlackBot DiffBot

Elixir application that compares users between **Slack** and **Microsoft** systems, highlighting discrepancies in user presence and name mismatches. It uses the Slack Web API and Microsoft Graph API, with results sent as a summary message.

---

## Features

- Fetches users from both Slack and Microsoft
- Detects users present in one system but not the other
- Finds users present in both systems but with different names
- Sends a formatted report via the `Messenger` module

---

## Project Structure

- `SlackBot.Client` – Fetches real users from Slack using the Slack API
- `SlackBot.MicrosoftClient` – Retrieves users from Microsoft (implementation assumed)
- `SlackBot.Messenger` – Sends comparison results (e.g., to Slack or elsewhere)
- `SlackBot.DiffBot` – The main logic for comparing users and formatting the output
- `SlackBot.PeopleForceClient` – Retrieves users from PeopleForce by parsing a CSV file containing employee data

The `SlackBot.PeopleForceClient` module parses a CSV file to retrieve users. It checks the email domain and excludes certain emails based on predefined rules.

### Example usage of `SlackBot.PeopleForceClient`:

```elixir
file_path = "priv/peopleforce/exports-employee-2025-05-05.csv"
users = SlackBot.PeopleForceClient.get_users(file_path)
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

    The comparison task will run automatically once a week. 
    
    However, you can also manually trigger it by running the following command:

    ```elixir
    SlackBot.DiffBot.run()
    ```

---

##  Example Output

🔵 In Microsoft, but not in Slack:

    Jane Doe jane.doe@example.com

🔵 In Slack, but not in Microsoft:

    John Smith john.smith@example.com

🔵 Present in both, but with different names:

    Email: alex@example.com
    Slack: Alexey Petrov
    Microsoft: Alexander Petrov
