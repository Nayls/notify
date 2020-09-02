#!/usr/bin/env bash

# DISCORD =====================================================================
: ${DISCORD_SENDER:="AllureBot"}
: ${DISCORD_USERNAME:="AutoTest Informer"}
: ${DISCORD_WEBHOOK:="http://undefined.localhost"}
: ${DISCORD_PING_ROLES:=""}

# TEST CI BLOCK ===============================================================
: ${CI_PAGES_URL:="http://undefined.localhost"}
: ${CI_SERVER_URL:="http://undefined.localhost"}
: ${CI_PIPELINE_URL:="http://undefined.localhost"}
: ${CI_PIPELINE_ID:="undefined"}
: ${CI_PROJECT_PATH:="undefined/undefined"}
: ${CI_PROJECT_URL:="http://undefined.localhost"}

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

: ${PRE_CI_PROJECT_NAME:="undefined/undefined"}
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
    "sender": "${DISCORD_SENDER}",
    "username": "${DISCORD_USERNAME}",
    "content": "\n${DISCORD_PING_ROLES}\n**${PRE_GITLAB_USER_NAME} (${PRE_GITLAB_USER_EMAIL})** in the project **[${PRE_CI_PROJECT_TITLE}]($PRE_CI_PROJECT_URL)** has been run for the environment - **[${PRE_CI_ENVIRONMENT_SLUG}](${PRE_CI_ENVIRONMENT_URL})**.",
    "allowed_mentions": {
        "parse": [],
        "users": [],
        "roles": []
    },
    "tts": false,
    "embeds": [{
        "url": "${CI_PAGES_URL}",
        "type": "rich",
        "title": "Results of automated testing",
        "description": "",
        "image": {
            "url": ""
        },
        "author": {
            "name": "${PRE_GITLAB_USER_NAME}",
            "url": "${CI_SERVER_URL}/${PRE_GITLAB_USER_LOGIN}",
            "icon_url": "https://cdn.iconscout.com/icon/free/png-512/avatar-375-456327.png"
        },
        "thumbnail": {
            "url": "https://img.icons8.com/dusk/128/000000/python.png"
        },
        "footer": {
            "text": "${CI_PROJECT_PATH}\npipeline: ${CI_PIPELINE_ID}  |  time: ${DURATION_VALUE}",
            "icon_url": "https://img.icons8.com/color/48/000000/gitlab.png"
        },
        "fields": [
            {
                "name": "Passed",
                "value": "${PASSED_VALUE}",
                "inline": true
            },
            {
                "name": "Failed / xFailed",
                "value": "${FAILED_VALUE} / ${XFAILED_VALUE}",
                "inline": true
            },
            {
                "name": "Skipped",
                "value": "${SKIPPED_VALUE}",
                "inline": true
            },
            {
                "name": "Trigger project",
                "value": "- environment: [${PRE_CI_ENVIRONMENT_SLUG}](${PRE_CI_ENVIRONMENT_URL}) \n- repo: [${PRE_CI_PROJECT_PATH}](${PRE_CI_PROJECT_URL}) \n- pipeline: [${PRE_CI_PIPELINE_ID}](${PRE_CI_PIPELINE_URL}) \n- branch: [${PRE_CI_COMMIT_REF_NAME}](${PRE_CI_PROJECT_URL}/-/tree/${PRE_CI_COMMIT_REF_SLUG}) \n- commit: [${PRE_CI_COMMIT_SHORT_SHA}](${PRE_CI_PROJECT_URL}/-/commit/${PRE_CI_COMMIT_SHA}) \n- user: [${PRE_GITLAB_USER_NAME}](${PRE_CI_SERVER_URL}/${PRE_GITLAB_USER_LOGIN}) \n- email: ${PRE_GITLAB_USER_EMAIL} \n",
                "inline": false
            }
        ]
    }]
}
EOF
}

$(generate_post_data)

if [[ "$1" = "-v" ]]; then
    cat data.json
fi

curl -S -L --fail -X POST "${DISCORD_WEBHOOK}" -H "Content-Type: application/json" --data-binary "@data.json" || exit 1