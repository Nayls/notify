#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# github.com/nayls-cloud/notify
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# github.com/nayls-cloud/notify/discord.sh
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
# notify
__base="$(basename ${__file} .sh)"
# github.com/nayls-cloud/
__root="$(cd "$(dirname "${__dir}")" && pwd)"


generate_post_data_for_trigger_project()
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

# generate_post_data_for_local_project()()
# {
#   cat > data.json << EOF
# {

# }
# EOF
# }


$(generate_post_data_for_trigger_project)

for i in "$@"
do
    case $i in
        "-v" | "--verbose" )
            cat data.json
            ;;

        "--data-binary" )
            echo "Not agreed, you can't proceed the installation";
            exit 1
            ;;
        * )
            printf '\n%s\n' "Usage: notify discord [OPTIONS]"
            printf '\n%s\n' "Options:"
            printf '\t%s,\t%s\t%s\n' "-v" "--verbose" "Print generated json (file data.json)"
            printf '\t%s\t%s\t%s\n' "" "--data-binary" "Use custom json for send (paster json in file \"data.json\")"
            ;;
    esac
done

# curl -S -L --fail -X POST "${DISCORD_WEBHOOK}" -H "Content-Type: application/json" --data-binary "@data.json" || exit 1
