#!/usr/bin/env bats

load test_helper

@test 'Create a git tag for the release.' {
  in_test_dir 'tag_created'
  echo 'VERSION=1.4-SNAPSHOT' > build.properties
  init_with_origin 'tag_created_origin'
  AUTO_VERSION=true run ./release build.properties
  [[ "$(git tag -l '1.4')" == '1.4' ]]
}

@test 'Include the version build.properties in the release tag.' {
  in_test_dir 'tag_props'
  echo 'VERSION=1.6-SNAPSHOT' > build.properties
  init_with_origin 'tag_props_origin'
  AUTO_VERSION=true run ./release build.properties
  git checkout '1.6'
  [[ "$(<build.properties)" = 'VERSION=1.6' ]]
}

