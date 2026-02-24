FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MKTCMS_TESTS_IN_DOCKER=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        findutils \
        grep \
        sed \
        git \
        openssl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY . /workspace

ENTRYPOINT ["bash", "tests/test-cli.sh"]