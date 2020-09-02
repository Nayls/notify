#!/usr/bin/env bash

# SLACK =======================================================================
: ${SLACK_USERNAME:="AutoTest Informer"}
: ${SLACK_WEBHOOK:="http://undefined.localhost"}
: ${SLACK_CHANNEL:="@undefined"}
: ${SLACK_ICON_URL:="https://img.icons8.com/dusk/100/000000/appointment-reminders.png"}
: ${SLACK_ATTACHMENT_COLOR:="#76c6f5"}

# TEST CI BLOCK ===============================================================
: ${CI_PAGES_URL:="http://undefined.localhost"}
: ${CI_SERVER_URL:="http://undefined.localhost"}
: ${CI_PIPELINE_URL:="http://undefined.localhost"}
: ${CI_PIPELINE_ID:="undefined"}
: ${CI_PROJECT_PATH:="undefined/undefined"}
: ${CI_PROJECT_URL:="http://undefined.localhost"}
: ${CI_COMMIT_SHA:="123123123123123123123"}
: ${CI_COMMIT_SHORT_SHA:="12312312"}

# TRIGGER PROJECT BLOCK =======================================================
: ${PRE_CI_SERVER_URL:="http://undefined.localhost"}

: ${PRE_CI_ENVIRONMENT_SLUG:="undefined"}
: ${PRE_CI_ENVIRONMENT_URL:="http://undefined.localhost"}

: ${PRE_CI_PIPELINE_SOURCE:="undefined"}
: ${PRE_CI_PIPELINE_URL:="http://undefined.localhost"}
: ${PRE_CI_PIPELINE_ID:="undefined"}

: ${PRE_CI_COMMIT_REF_NAME:="undefined"}
: ${PRE_CI_COMMIT_REF_SLUG:="undefined"}
: ${PRE_CI_COMMIT_SHA:="undefined"}
: ${PRE_CI_COMMIT_SHORT_SHA:="undefined"}

: ${PRE_CI_JOB_NAME:="undefined"}

: ${PRE_CI_PROJECT_NAME:="undefined"}
: ${PRE_CI_PROJECT_TITLE:="undefined"}
: ${PRE_CI_PROJECT_URL:="http://undefined.localhost"}
: ${PRE_CI_PROJECT_PATH:="undefined/undefined"}

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
            "pretext": "\n*${PRE_GITLAB_USER_NAME} (${PRE_GITLAB_USER_EMAIL})* in the project *<${PRE_CI_PROJECT_URL}|${PRE_CI_PROJECT_TITLE}>* has been run for the environment - *${PRE_CI_ENVIRONMENT_SLUG}*.",
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
                    "title": "Skipped",
                    "value": "${SKIPPED_VALUE}",
                    "short": true
                },
                {
                    "title": "Failed ",
                    "value": "${FAILED_VALUE}",
                    "short": true
                },
                {
                    "title": "xFailed",
                    "value": "${XFAILED_VALUE}",
                    "short": true
                },
                {
                    "title": "Trigger project",
                    "value": "- environment: ${PRE_CI_ENVIRONMENT_SLUG} \n- repo: <${PRE_CI_PROJECT_URL}|${PRE_CI_PROJECT_PATH}> \n- pipeline: <${PRE_CI_PIPELINE_URL}|${PRE_CI_PIPELINE_ID}> \n- branch: <${PRE_CI_PROJECT_URL}/-/tree/${PRE_CI_COMMIT_REF_SLUG}|${PRE_CI_COMMIT_REF_NAME}> \n- commit: <${PRE_CI_PROJECT_URL}/-/commit/${PRE_CI_COMMIT_SHA}|${PRE_CI_COMMIT_SHORT_SHA}> \n- user: <${PRE_CI_SERVER_URL}/${PRE_GITLAB_USER_LOGIN}|${PRE_GITLAB_USER_NAME}> \n- email: ${PRE_GITLAB_USER_EMAIL} \n",
                    "short": false
                }
            ],
            "thumb_url": "https://img.icons8.com/dusk/128/000000/python.png",
            "footer": "<${CI_PROJECT_URL}|${CI_PROJECT_PATH}> \npipeline: <${CI_PIPELINE_URL}|${CI_PIPELINE_ID}>  |  time: ${DURATION_VALUE}",
            "footer_icon": "https://img.icons8.com/color/48/000000/gitlab.png"
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