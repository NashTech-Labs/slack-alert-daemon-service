# Monitoring Daemon Service and sending alerts on Slack

![Slack](https://editor.analyticsvidhya.com/uploads/37991Slack_logo_new.png) 

We will be using bash scripting and Slack Webhook Integration to monitor daemon Services and send Slack alerts based on the state of the service. This script works on the Linux distros which uses bash shell and systemctl to manage services.

## Configure Webhook for a Slack Channel

We need to integrate the Slack App `Incoming Webhooks` to the Slack channel we want to send alerts to.
* So we need to add `Incoming Webhooks` to the app directory in Slack.

![Incoming Webhook](https://github.com/knoldus/slack-alert-daemon-service/blob/feat/images/slack-app.png?raw=true)

* Then we select a channel to integrate the webhook to

![channel](https://github.com/knoldus/slack-alert-daemon-service/blob/feat/images/slack-channel.png?raw=true)
 
* When we integrate the webhook, we will get the link for the webhook which we will be using later for sending alerts. So store the Webhook URL safely.

![Webhook URL](https://github.com/knoldus/slack-alert-daemon-service/blob/feat/images/slack-hook-url.jpg?raw=true)

## Executing the script
The script uses environment variables and arguments to configure:
* Service to be monitored
* Interval between successive notification alerts
* The webhook URL where the alert is to be sent (the URL we stored previously)

The script when executed with the above environment variables monitors the state of the service using `systemctl status` command. If the status shows `failed`, the script attempts to `restart the service`. If the service is `stopped` by default or is `stopped` by someone, it attempts to `restart the service`. If the attempt to `restart` fails, an alert is sent after `${NOTIFY}` interval until it succeeds. After it succeeds, an alert is sent that the service has been `started successfully` and does not send alerts further down the line until the service `fails or is stopped`. Hence the script needs `root privileges` as it manages the services.
#### Execute the following commands to configure the environment variables:
* `export NOTIFY=<Notification Interval>`
* `export WEBHOOK_URL= https://hooks.slack.com/services/XXXXXXXXXXXXXXX`
#### Execute the following command to start the script:
`sudo ./slack-daemon-alerts.sh <service name> $WEBHOOK_URL`

##### To execute the script in background:

`sudo ./slack-daemon-alerts.sh <service name> $WEBHOOK_URL &`


## Alert Snapshot
Here I have used the script to monitor `jenkins.service` with the script:
```
export NOTIFY=120
export WEBHOOK_URL= https://hooks.slack.com/services/XXXXXXXXXXXXXXX
sudo ./slack-daemon-alerts.sh jenkins $WEBHOOK_URL
```
#### Service Failed Snapshot

![Failed](https://github.com/knoldus/slack-alert-daemon-service/blob/feat/images/alert-failed.png?raw=true)

#### Service Stopped Snapshot

![Stopped](https://github.com/knoldus/slack-alert-daemon-service/blob/feat/images/alert-stopped.png?raw=true)

#### Service Started Snapshot

![Started](https://github.com/knoldus/slack-alert-daemon-service/blob/feat/images/aler-started.png?raw=true)

Incase of any queries, you can email me at: [dipayan.pramanik@knoldus.com](dipayan.pramanik@knoldus.com)