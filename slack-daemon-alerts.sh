#!/bin/bash

# MONITORING AND SLACK ALERTS OF DAEMON PROCESS 


SLACK_URL=$2

while [ true ]
do

    NOTIFY_INTERVAL=${NOTIFY:-10}           #Alert Interval

    
    ## Grep the Status of the Daemon Process if its is running or inactive

    STATUS=$(systemctl status $1 | awk '/Active/{print $2}')
    SERVICE=$(systemctl status $1 | awk '{if ( NR == 1)print $2}')
    BLANK_LINE_NUM=$(systemctl status $1 | awk '/^$/{print NR; exit}')
    LOGS=$(systemctl status $1 | awk -v no=$BLANK_LINE_NUM  '{if( NR > no ) print $0 }')

    ## Trigger Webhook to send alert to the slack channel when the daemon fails

    if [[ $STATUS = "failed" ]]
    then
        curl -X POST -H 'Content-type: application/json' --data "{
        \"text\": \"*Daemon Process Failed*\",
        \"attachments\": [
            {
                \"text\": \"*Service*: _${SERVICE}_\n*Status*: _${STATUS}_\n _*Logs*_\n\`\`\`${LOGS}\`\`\`\",
                \"color\": \"#FF0000\"
            }

        ]
    }" $SLACK_URL
   
   sleep $NOTIFY_INTERVAL

    ##### Recheck if the Daemon process is up and running

    while [[ $STATUS = "failed" ]]
    do

        systemctl start ${SERVICE}


        until [[ $STATUS = "active" ]]
        do

            STATUS=$(systemctl status $1 | awk '/Active/{print $2}')
            SERVICE=$(systemctl status $1 | awk '{if ( NR == 1)print $2}')
            BLANK_LINE_NUM=$(systemctl status $1 | awk '/^$/{print NR; exit}')
            LOGS=$(systemctl status $1 | awk -v no=$BLANK_LINE_NUM  '{if( NR > no ) print $0 }')

            if [[ $STATUS = "failed" ]]
            then
                break
            fi
            sleep 5
        
        done



        ###### If the Daemon Process has started then send a slack green alert

        if [[ $STATUS = "active" ]]
        then
            curl -X POST -H 'Content-type: application/json' --data "{
                \"text\": \"*Daemon Process Running*\",
                \"attachments\": [
                    {
                        \"text\": \"*Service*: _${SERVICE}_\n*Status*: _${STATUS}_\n *Service Started Successfully*\",
                        \"color\": \"#00FF00\"
                    }

                ]
            }" $SLACK_URL



        #### If the Daemon Process has failed then send slack red alert again
    

        elif [[ $STATUS = "failed" ]]
        then
            curl -X POST -H 'Content-type: application/json' --data "{
                \"text\": \"*Daemon Process Failed*\",
                \"attachments\": [
                    {
                        \"text\": \"*Service*: _${SERVICE}_\n*Status*: _${STATUS}_\n _*Logs*_\n\`\`\`${LOGS}\`\`\`\",
                        \"color\": \"#FF0000\"
                    }

                ]
            }" $SLACK_URL
            
            sleep $NOTIFY_INTERVAL
        fi
    done


    #### Check if the Daemon has been stopped

    elif [[ $STATUS = "inactive" ]]
    then
        curl -X POST -H 'Content-type: application/json' --data "{
            \"text\": \"*Daemon Process Stopped*\",
            \"attachments\": [
                {
                    \"text\": \"*Service*: _${SERVICE}_\n*Status*: _${STATUS}_\n *Service is Stopped manually or has never been started*\n *Attempting to Start the Service*\",
                    \"color\": \"#808080\"
                }

                ]
        }" $SLACK_URL


        systemctl start ${SERVICE}
    

        until [[ $STATUS = "active" ]]
        do
            STATUS=$(systemctl status $1 | awk '/Active/{print $2}')
            SERVICE=$(systemctl status $1 | awk '{if ( NR == 1)print $2}')
            BLANK_LINE_NUM=$(systemctl status $1 | awk '/^$/{print NR; exit}')
            LOGS=$(systemctl status $1 | awk -v no=$BLANK_LINE_NUM  '{if( NR > no ) print $0 }')

            sleep 5

            if [[ $STATUS = "failed" ]]
            then
                break
            fi
            

        done

        if [[ $STATUS = "failed" ]]
            then
                continue
            fi

        curl -X POST -H 'Content-type: application/json' --data "{
                \"text\": \"*Daemon Process Running*\",
                \"attachments\": [
                    {
                        \"text\": \"*Service*: _${SERVICE}_\n*Status*: _${STATUS}_\n *Service Started Successfully*\",
                        \"color\": \"#00FF00\"
                    }

                ]
            }" $SLACK_URL

    fi

    sleep $NOTIFY_INTERVAL
done