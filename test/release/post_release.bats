#!/usr/bin/env bats

load test_helper

@test 'When done releasing, increment last doublet version number in build.properties.' {
  in_test_dir 'version_bump'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'version_bump_origin'
  AUTO_VERSION=true run ./release build.properties
  [[ "$(<build.properties)" == 'VERSION=1.1-SNAPSHOT' ]]
}

@test 'When done releasing, increment last triplet version number in build.properties.' {
  in_test_dir 'version_bump'
  echo 'VERSION=1.2.9-SNAPSHOT' > build.properties
  init_with_origin 'version_bump_origin'
  AUTO_VERSION=true run ./release build.properties
  [[ "$(<build.properties)" == 'VERSION=1.2.10-SNAPSHOT' ]]
}

@test 'When done releasing, git is synched.' {
  in_test_dir 'post_synched'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'post_synched_origin'
  AUTO_VERSION=true run ./release build.properties
  [[ -z "$(git status -s)" ]]
}

@test 'Reflect the release in the git log.' {
  in_test_dir 'logs'
  echo 'VERSION=2.3.2-SNAPSHOT' > build.properties
  init_with_origin 'logs_origin'
  AUTO_VERSION=true run ./release build.properties
  mapfile -t logs < <(git log HEAD~2..HEAD --oneline --no-decorate | cut -d ' ' -f2-)
  [[ "${logs[0]}" == 'Post release version 2.3.3-SNAPSHOT' ]]
  [[ "${logs[1]}" == 'Update to version 2.3.2' ]]
}
