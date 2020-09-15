#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# github.com/nayls-cloud/notify
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# github.com/nayls-cloud/notify/notify.sh
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
# notify
__base="$(basename ${__file} .sh)"
# github.com/nayls-cloud/
__root="$(cd "$(dirname "${__dir}")" && pwd)"


# DISCORD =====================================================================
: ${DISCORD_SENDER:="AllureBot"}
: ${DISCORD_USERNAME:="AutoTest Informer"}
: ${DISCORD_WEBHOOK:="http://undefined.localhost"}
: ${DISCORD_PING_ROLES:=""}

# SLACK =======================================================================
: ${SLACK_USERNAME:="AutoTest Informer"}
: ${SLACK_WEBHOOK:="http://undefined.localhost"}
: ${SLACK_CHANNEL:="@undefined"}
: ${SLACK_ICON_URL:="https://img.icons8.com/dusk/100/000000/appointment-reminders.png"}
: ${SLACK_ATTACHMENT_COLOR:="#76c6f5"}
: ${SLACK_PING_ROLES:=""}

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
: ${PYTEST_RESULT_PATH:="results/pytest_result.json"}

if [ -f "${PYTEST_RESULT_PATH}" ]; then
    : ${PASSED_VALUE:=$(cat results/pytest_result.json | jq -r '.passed')}
    : ${FAILED_VALUE:=$(cat results/pytest_result.json | jq -r '.failed')}
    : ${XFAILED_VALUE:=$(cat results/pytest_result.json | jq -r '.xfailed')}
    : ${SKIPPED_VALUE:=$(cat results/pytest_result.json | jq -r '.skipped')}
    : ${DURATION_VALUE:=$(cat results/pytest_result.json | jq -r '.duration')}
else
    : ${PASSED_VALUE:="undefined"}
    : ${FAILED_VALUE:="undefined"}
    : ${XFAILED_VALUE:="undefined"}
    : ${SKIPPED_VALUE:="undefined"}
    : ${DURATION_VALUE:="undefined"}
fi


COMMAND=""

for i in "$@"
do
    case $i in
        "-v" | "--verbose" )
            COMMAND="${COMMAND} ${i}"
            ;;

        "--data-binary" )
            COMMAND="${COMMAND} ${i}"
            ;;

        * )
            printf '\n%s\n' "Usage: notify [OPTIONS] COMMAND"
            printf '\n%s\n' "Options:"
            printf '\t%s,\t%s\t%s\n' "-v" "--verbose" "Print generated json (file data.json)"
            printf '\t%s\t%s\t%s\n' "" "--data-binary" "Use custom json for send (paster json in file \"data.json\")"
            printf '\n%s\n' "Commands:"
            printf '\t%s\t%s\n' "discord" "Send message to discord"
            printf '\t%s\t%s\n' "slack" "Send message to slack"
            printf '\n%s\n' "Run 'notify COMMAND --help' for more information on a command."
            break
            ;;
    esac
done


echo "DEBUG: notify ${COMMAND}"

# ${__file} "${COMMAND}"
