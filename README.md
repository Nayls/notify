<!--
Title: Notify
Description: Docker image with frequently used packages jq, gettext, curl, openssl, ca-certificates, bash, make, and Bash scripts for sending notifications to Discord and Slack about the status of passing Pytest tests.
Author: Svyatoslav Gagarin (Nayls)
-->

# Notify

![Docker Image Version (latest semver)](https://img.shields.io/docker/v/naylscloud/notify?style=flat-square)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/naylscloud/notify?style=flat-square)
![MicroBadger Layers](https://img.shields.io/microbadger/layers/naylscloud/notify/latest?style=flat-square)

![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/naylscloud/notify?style=flat-square)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/naylscloud/notify?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/naylscloud/notify?style=flat-square)
![Docker Stars](https://img.shields.io/docker/stars/naylscloud/notify?style=flat-square)

Docker image with frequently used packages `jq`, `gettext`, `curl`, `openssl`, `ca-certificates`, `bash`, `make`, and `Bash` scripts for sending notifications to `Discord` and `Slack` about the status of passing `Pytest` tests.

Implemented only for `PyTest`.

![notify](https://live.staticflickr.com/65535/50302236153_acb962d466_o.png)

## Supported tags and respective Dockerfile links

[`1.0`, `latest`](Dockerfile)

```bash
docker pull naylscloud/notify
```

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

```bash
# OpenSUSE
zypper install jq curl bash
```
or
```bash
# Ubuntu/Debian
apt install jq curl bash
```

If you want to build a docker image, you need docker installed on your system.
How to install docker in [OpenSUSE](https://en.opensuse.org/Docker) or [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

### Installing

A step by step series of examples that tell you have to get a development env running

Add `conftest.py` to the end so that after running the tests, the results of the run appear in the console and as a file pytest_result.json

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

Now you can run py test and see the result in the console. it will also be in the file, `results/pytest_result.json`

```bash
pytest -rsq
    --strict-markers
    --tb=short
    --color=yes
```

This is example console output after running tests

```bash
----------------------------- Captured log setup -----------------------------
passed amount: 1
failed amount: 1
xfailed amount: 0
skipped amount: 0
duration: 45.272
========================= 1 failed, 1 passed in 45.27s ========================
```

The `results/pytest_result.json` file will also appear, which is used for uploading as artifact from `e2e` job to `discord` or `slack`

```json
{"passed": 1, "failed": 1, "xfailed": 0, "skipped": 0, "duration": "45.272"}
```

To send a notification, you must either override all variables found in `discord.sh` or `slack.sh` or run from the console, for example

```bash
DISCORD_WEBHOOK=https://discordapp.com/api/webhooks/<secret> discord.sh -v
```

## Deployment

Add a job to the project that will trigger your project with tests
Here it is extremely important to pass pre_* variables to the project with tests.

```yaml
stages:
    - trigger

test-project-trigger:
    stage: trigger
    variables:
        PRE_CI_SERVER_URL: ${CI_SERVER_URL}

        PRE_CI_ENVIRONMENT_SLUG: test
        PRE_CI_ENVIRONMENT_URL: https://undefined.localhost/

        PRE_CI_PIPELINE_SOURCE: ${CI_PIPELINE_SOURCE}
        PRE_CI_PIPELINE_URL: ${CI_PIPELINE_URL}
        PRE_CI_PIPELINE_ID: ${CI_PIPELINE_ID}

        PRE_CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}
        PRE_CI_COMMIT_SHA: ${CI_COMMIT_SHA}

        PRE_CI_COMMIT_REF_NAME: ${PRE_CI_COMMIT_REF_NAME}
        PRE_CI_COMMIT_REF_SLUG: ${PRE_CI_COMMIT_REF_SLUG}
        PRE_CI_COMMIT_SHA: ${PRE_CI_COMMIT_SHA}
        PRE_CI_COMMIT_SHORT_SHA: ${PRE_CI_COMMIT_SHORT_SHA}

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

Example .gitlab-ci. yml of the project where your tests are locate

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_TAG
    - if: $CI_COMMIT_BRANCH

stages:
  - test
  - inform

e2e:
  image: python:3.8-alpine
  stage: test
  variables:
    PYTEST_NUMPROCESSES: 4
  artifacts:
    name: "$CI_JOB_NAME-$CI_COMMIT_REF_SLUG"
    expose_as: 'pytest result'
    paths:
      - results/
    expire_in: 3 days
  before_script:
    - apk add --update --no-cache make bash
    - pip3 install pipenv
    - pipenv install --system
  script:
    - pytest -rsq
      --strict-markers
      --tb=short
      --numprocesses=${PYTEST_NUMPROCESSES}
      --color=yes
      --html=results/html/report.html
  rules:
    - if: '$CI_MANUAL == "true" || $CI_COMMIT_REF_NAME =~ /^hotfix\//'
      when: manual
      allow_failure: true
    - if: '$CI_PIPELINE_SOURCE == "web" || $CI_PIPELINE_SOURCE == "pipeline" || $CI_PIPELINE_SOURCE == "trigger"'
      when: on_success
    - when: never

discord:
  image: naylscloud/notify:latest
  stage: inform
  variables:
    GIT_STRATEGY: none
    # DISCORD_WEBHOOK: "https://discordapp.com/api/webhooks/<secret>"
    # DISCORD_PING_ROLES: "<@&idrole>" # \@role in discord chat
  dependencies:
    - e2e
  script:
    - discord -v
  rules:
    - if: '$CI_MANUAL == "true" || $CI_COMMIT_REF_NAME =~ /^hotfix\//'
      when: manual
      allow_failure: true
    - if: '$CI_PIPELINE_SOURCE == "web" || $CI_PIPELINE_SOURCE == "pipeline" || $CI_PIPELINE_SOURCE == "trigger"'
      when: on_success
    - when: never

slack:
  image: naylscloud/notify:latest
  stage: inform
  variables:
    GIT_STRATEGY: none
    # SLACK_WEBHOOK: "https://hooks.slack.com/services/<secret>"
    # SLACK_CHANNEL: "#general"
    # SLACK_PING_ROLES: "@user_or_role"
  dependencies:
    - e2e
  script:
    - slack -v
  rules:
    - if: '$CI_MANUAL == "true" || $CI_COMMIT_REF_NAME =~ /^hotfix\//'
      when: manual
      allow_failure: true
    - if: '$CI_PIPELINE_SOURCE == "web" || $CI_PIPELINE_SOURCE == "pipeline" || $CI_PIPELINE_SOURCE == "trigger"'
      when: on_success
    - when: never
```

## Built With

* [bash](https://www.gnu.org/software/bash/bash.html) - The GNU Bourne Again shell
* [curl](https://curl.haxx.se/) - An URL retrieval utility and library
* [jq](https://stedolan.github.io/jq/) - Command-line JSON processor

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/nayls-cloud/notify/tags).

## Authors

* **Svyatoslav Gagarin** - *Initial work* - [Nayls](https://github.com/Nayls)

See also the list of [contributors](https://github.com/nayls-cloud/notify/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
