FROM bats/bats:v1.1.0

RUN apk --no-cache --update add git

RUN adduser -S bats

USER bats

RUN git config --global user.email 'buildsrc@example.com' && \
    git config --global user.name 'buildsrc tests'
