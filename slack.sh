#!/usr/bin/env bash

# SLACK =======================================================================
: ${SLACK_USERNAME:="AutoTest Informer"}
: ${SLACK_WEBHOOK:="undefined"}
: ${SLACK_CHANNEL:="undefined"}
: ${SLACK_ICON_URL:="https://img.icons8.com/dusk/100/000000/appointment-reminders.png"}
: ${SLACK_ATTACHMENT_COLOR:="#76c6f5"}

# TEST CI BLOCK ===============================================================
: ${CI_PAGES_URL:="undefined"}
: ${CI_SERVER_URL:="undefined"}
: ${CI_PROJECT_PATH:="undefined"}
: ${CI_PIPELINE_ID:="undefined"}

# TRIGGER PROJECT BLOCK =======================================================
: ${PRE_CI_ENVIRONMENT_SLUG:="undefined"}
: ${PRE_CI_ENVIRONMENT_URL:="undefined"}

: ${PRE_CI_PIPELINE_URL:="undefined"}
: ${PRE_CI_PIPELINE_SOURCE:="undefined"}
: ${PRE_CI_PIPELINE_ID:="undefined"}

: ${PRE_CI_COMMIT_REF_NAME:="undefined"}
: ${PRE_CI_COMMIT_SHA:="undefined"}

: ${PRE_CI_JOB_NAME:="undefined"}

: ${PRE_CI_PROJECT_NAME:="undefined"}
: ${PRE_CI_PROJECT_TITLE:="undefined"}
: ${PRE_CI_PROJECT_URL:="undefined"}
: ${PRE_CI_PROJECT_PATH:="undefined"}

: ${PRE_GITLAB_USER_NAME:="undefined"}
: ${PRE_GITLAB_USER_LOGIN:="undefined"}
: ${PRE_GITLAB_USER_EMAIL:="undefined"}

# PYTEST INFO =================================================================
: ${PASSED_VALUE:="undefined"}
: ${FAILED_VALUE:="undefined"}
: ${XFAILED_VALUE:="undefined"}
: ${SKIPPED_VALUE:="undefined"}
: ${DURATION_VALUE:="undefined"}

generate_post_data()
{
  cat > data.json << EOF
{
    "username": "${SLACK_USERNAME}",
    "channel": "${SLACK_CHANNEL}",
    "mrkdwn": true,
    "icon_url": "${SLACK_ICON_URL}",
    "attachments": [
        {
	        "mrkdwn_in": ["text"],
            "color": "${SLACK_ATTACHMENT_COLOR}",
            "pretext": "\n**${PRE_GITLAB_USER_NAME} (${PRE_GITLAB_USER_EMAIL})** in the project **[${PRE_CI_PROJECT_TITLE}]($PRE_CI_PROJECT_URL)** has been run for the environment - **${PRE_CI_ENVIRONMENT_SLUG}**.",
            "author_name": "${PRE_GITLAB_USER_NAME}",
            "author_link": "${CI_SERVER_URL}/${PRE_GITLAB_USER_LOGIN}",
            "author_icon": "https://cdn.iconscout.com/icon/free/png-512/avatar-375-456327.png",
            "title": "Results of automated testing",
            "title_link": "${CI_PAGES_URL}",
            "text": "",
            "fields": [
                {
                    "title": "Passed",
                    "value": "${PASSED_VALUE}",
                    "short": true
                },
                {
                    "title": "Failed / xFailed",
                    "value": "${FAILED_VALUE} / ${XFAILED_VALUE}",
                    "short": true
                },
                {
                    "title": "Skipped",
                    "value": "A second short field's value",
                    "short": true
                },
                {
                    "title": "Trigger project",
                    "value": "- environment: ${PRE_CI_ENVIRONMENT_SLUG} \n- repo: [${PRE_CI_PROJECT_PATH}](${PRE_CI_PROJECT_URL}) \n- pipeline: [${PRE_CI_PIPELINE_ID}](${PRE_CI_PIPELINE_URL}) \n- branch: ${PRE_CI_COMMIT_REF_NAME} \n- user: ${PRE_GITLAB_USER_NAME} \n- email: ${PRE_GITLAB_USER_EMAIL} \n",
                    "short": false
                }
            ],
            "thumb_url": "https://img.icons8.com/dusk/128/000000/python.png",
            "footer": "${CI_PROJECT_PATH}\npipeline: ${CI_PIPELINE_ID}  |  time: ${DURATION_VALUE}",
            "footer_icon": "https://img.icons8.com/color/48/000000/gitlab.png",
        }
    ]
}
EOF
}

$(generate_post_data)

if [[ "$1" = "-v" ]]; then
    cat data.json
fi

curl -S -L --fail -X POST "${SLACK_WEBHOOK}" -H "Content-Type: application/json" --data-binary "@data.json" || exit 1