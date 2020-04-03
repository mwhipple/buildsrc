#!/usr/bin/env bats

load test_helper

@test 'When everything is in order, return success.' {
    in_test_dir 'tag_version'
    echo 'VERSION=1.0-SNAPSHOT' > build.properties
    init_with_origin 'tag_version_origin'
    AUTO_VERSION=true run ./release build.properties
    git checkout '1.0'
    (( "${status}" == 0 ))
}

@test 'When releasing, tag build.properties with released version.' {
    in_test_dir 'tag_version'
    echo 'VERSION=1.0-SNAPSHOT' > build.properties
    init_with_origin 'tag_version_origin'
    AUTO_VERSION=true run ./release build.properties
    git checkout '1.0'
    [[ "$(<build.properties)" == 'VERSION=1.0' ]]
}

@test 'When done releasing, remove lock file.' {
    in_test_dir 'tag_version'
    echo 'VERSION=1.0-SNAPSHOT' > build.properties
    init_with_origin 'tag_version_origin'
    AUTO_VERSION=true run ./release build.properties
    [[ ! -f build.properties.releasing ]]
}

