#!/usr/bin/env bats

load test_helper

@test 'When on custom master branch, return success.' {
  in_test_dir 'nonmaster'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'nonmaster_origin'
  git checkout -B other
  git push --set-upstream origin other
  RELEASE_MASTER=other AUTO_VERSION=true run ./release build.properties
  (( "${status}" == 0 ))
}

@test 'When using custom remote, return success.' {
  in_test_dir 'nonmaster'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'nonmaster_origin'
  git remote rename origin upstream
  RELEASE_REMOTE=upstream AUTO_VERSION=true run ./release build.properties
  (( "${status}" == 0 ))
}
