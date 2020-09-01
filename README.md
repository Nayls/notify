# notify

[![](https://images.microbadger.com/badges/version/naylscloud/notify:latest.svg)](https://microbadger.com/images/naylscloud/notify:latest)
[![](https://images.microbadger.com/badges/image/naylscloud/notify:latest.svg)](https://microbadger.com/images/naylscloud/notify:latest)

> `1.1`,`latest`

```
DOCKER_BUILDKIT=1 docker build -t nayls-cloud/notify ./
```

## How to use

Pipeline - Trigger project

```yaml
stages:
    - trigger

test-trigger:
    stage: trigger
    variables:
        PRE_CI_ENVIRONMENT_SLUG: test
        PRE_CI_ENVIRONMENT_URL: https://google.com

        PRE_CI_PIPELINE_URL: ${CI_PIPELINE_URL}
        PRE_CI_PIPELINE_SOURCE: ${CI_PIPELINE_SOURCE}
        PRE_CI_PIPELINE_ID: ${CI_PIPELINE_ID}

        PRE_CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}
        PRE_CI_COMMIT_SHA: ${CI_COMMIT_SHA}

        PRE_CI_JOB_NAME: ${CI_JOB_NAME}

        PRE_CI_PROJECT_NAME: ${CI_PROJECT_NAME}
        PRE_CI_PROJECT_TITLE: ${CI_PROJECT_TITLE}
        PRE_CI_PROJECT_URL: ${CI_PROJECT_URL}
        PRE_CI_PROJECT_PATH: ${CI_PROJECT_PATH}

        PRE_GITLAB_USER_NAME: ${GITLAB_USER_NAME}
        PRE_GITLAB_USER_LOGIN: ${GITLAB_USER_LOGIN}
        PRE_GITLAB_USER_EMAIL: ${GITLAB_USER_EMAIL}
    trigger:
        project: gitlab.com/nayls/example_trigger
        branch: master
        strategy: depend
```

Pipeline test project

```yaml

discord:
  image: naylscloud/curl:7.69
  stage: notify
  variables:
    GIT_STRATEGY: none

    DISCORD_WEBHOOK: "http://google.com"
    DISCORD_ROLE_QA: "undefined"

    PRE_CI_ENVIRONMENT_SLUG: "undefined"
    PRE_CI_ENVIRONMENT_URL: "undefined"

    PRE_CI_PIPELINE_URL: "undefined"
    PRE_CI_PIPELINE_SOURCE: "undefined"
    PRE_CI_PIPELINE_ID: "undefined"

    PRE_CI_COMMIT_REF_NAME: "undefined"
    PRE_CI_COMMIT_SHA: "undefined"

    PRE_CI_JOB_NAME: "undefined"

    PRE_CI_PROJECT_NAME: "undefined"
    PRE_CI_PROJECT_TITLE: "undefined"
    PRE_CI_PROJECT_URL: "undefined"
    PRE_CI_PROJECT_PATH: "undefined"

    PRE_GITLAB_USER_NAME: "undefined"
    PRE_GITLAB_USER_LOGIN: "undefined"
    PRE_GITLAB_USER_EMAIL: "undefined"

    PASSED_VALUE: "undefined"
    FAILED_VALUE: "undefined"
    XFAILED_VALUE: "undefined"
    SKIPPED_VALUE: "undefined"
    DURATION_VALUE: "undefined"
  before_script:
    - PASSED_VALUE=$(cat results/pytest_result.json | jq -r '.passed')
    - FAILED_VALUE=$(cat results/pytest_result.json | jq -r '.failed')
    - XFAILED_VALUE=$(cat results/pytest_result.json | jq -r '.xfailed')
    - SKIPPED_VALUE=$(cat results/pytest_result.json | jq -r '.skipped')
    - DURATION_VALUE=$(cat results/pytest_result.json | jq -r '.duration')
```

Add in conftest.py

```python
def pytest_terminal_summary(terminalreporter, exitstatus, config):
    import time
    passed_count = len(terminalreporter.stats.get("passed", []))
    failed_count = len(terminalreporter.stats.get("failed", []))
    xfailed_count = len(terminalreporter.stats.get("xfailed", []))
    skipped_count = len(terminalreporter.stats.get("skipped", []))
    duration = format(time.time() - terminalreporter._sessionstarttime, '.3f')

    print("passed amount:", passed_count)
    print("failed amount:", failed_count)
    print("xfailed amount:", xfailed_count)
    print("skipped amount:", skipped_count)
    print("duration:", duration)

    import json
    data = {}
    data["passed"] = passed_count
    data["failed"] = failed_count
    data["xfailed"] = xfailed_count
    data["skipped"] = skipped_count
    data["duration"] = duration

    with open("results/pytest_result.json", "w") as outfile:
        json.dump(data, outfile)
```