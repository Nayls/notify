#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# github.com/nayls-cloud/notify
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# github.com/nayls-cloud/notify/slack.sh
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
# notify
__base="$(basename ${__file} .sh)"
# github.com/nayls-cloud/
__root="$(cd "$(dirname "${__dir}")" && pwd)"


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
            "pretext": "\n${SLACK_PING_ROLES}\n*${PRE_GITLAB_USER_NAME} (${PRE_GITLAB_USER_EMAIL})* in the project *<${PRE_CI_PROJECT_URL}|${PRE_CI_PROJECT_TITLE}>* has been run for the environment - *<${PRE_CI_ENVIRONMENT_URL}|${PRE_CI_ENVIRONMENT_SLUG}>*.",
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
                    "value": "- environment: <${PRE_CI_ENVIRONMENT_URL}|${PRE_CI_ENVIRONMENT_SLUG}> \n- repo: <${PRE_CI_PROJECT_URL}|${PRE_CI_PROJECT_PATH}> \n- pipeline: <${PRE_CI_PIPELINE_URL}|${PRE_CI_PIPELINE_ID}> \n- branch: <${PRE_CI_PROJECT_URL}/-/tree/${PRE_CI_COMMIT_REF_SLUG}|${PRE_CI_COMMIT_REF_NAME}> \n- commit: <${PRE_CI_PROJECT_URL}/-/commit/${PRE_CI_COMMIT_SHA}|${PRE_CI_COMMIT_SHORT_SHA}> \n- user: <${PRE_CI_SERVER_URL}/${PRE_GITLAB_USER_LOGIN}|${PRE_GITLAB_USER_NAME}> \n- email: ${PRE_GITLAB_USER_EMAIL} \n",
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
