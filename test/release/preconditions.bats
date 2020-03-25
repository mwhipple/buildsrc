#!/usr/bin/env bats

load test_helper

@test 'When git is not found, return failure status.' {
  in_test_dir 'bad_config'
  export GIT=./git
  run ./release
  (( "${status}" == 1 ))
}

@test 'When git is not found, output a fitting message.' {
  in_test_dir 'bad_config'
  export GIT=./git
  run ./release
  [[ "${output}" =~ ERROR.*git ]]
}

@test 'When argument is omitted, return failure status.' {
  in_test_dir 'bad_config'
  run ./release
  (( "${status}" == 1 ))
}

@test 'When argument is omitted, output usage info.' {
  in_test_dir 'bad_config'
  run ./release
  [[ "${output}" == *Usage* ]]
}

@test 'When properties is missing, return failure status.' {
  in_test_dir 'bad_config'
  run ./release missing.properties
  (( "${status}" == 1 ))
}

@test 'When properties is missing, output a fitting message.' {
  in_test_dir 'bad_config'
  run ./release missing.properties
  [[ "${output}" =~ ERROR.*not\ present ]]
}

@test 'When properties is not a regular file, return failure status.' {
  in_test_dir 'bad_config'
  mkdir dir1.properties
  run ./release dir1.properties
  (( "${status}" == 1 ))
}

@test 'When properties is not a regular file, output a fitting message.' {
  in_test_dir 'bad_config'
  mkdir dir2.properties
  run ./release dir2.properties
  [[ "${output}" =~ ERROR.*not\ a\ file ]]
}

@test 'When properties is not writable, return failure status.' {
  in_test_dir 'bad_config'
  touch unwritable.properties && chmod -w unwritable.properties
  run ./release unwritable.properties
  (( "${status}" == 1 ))
}

@test 'When properties is not writable, output a fitting message.' {
  in_test_dir 'bad_config'
  touch unwritable.properties && chmod -w unwritable.properties
  run ./release unwritable.properties
  [[ "${output}" =~ ERROR.*writable ]]
}

@test 'When lock file already exists, return failure status.' {
  in_test_dir 'bad_config'
  touch locked.properties && touch locked.properties.releasing
  run ./release locked.properties
  (( "${status}" == 1 ))
}

@test 'When lock file already exists, output a fitting message.' {
  in_test_dir 'bad_config'
  touch locked.properties && touch locked.properties.releasing
  run ./release locked.properties
  [[ "${output}" =~ ERROR.*already ]]
}

@test 'When outside of a git repository, return failure status.' {
  in_test_dir 'bad_config'
  touch build.properties
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When outside of a git repository, output a fitting message.' {
  in_test_dir 'bad_config'
  touch build.properties
  run ./release build.properties
  [[ "${output}" =~ git\ repository ]]
}

@test 'When VERSION is not set, return failure status.' {
  in_test_dir 'no_version'
  touch build.properties
  init_with_origin 'no_version_origin'
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When VERSION is not set, output a fitting message.' {
  in_test_dir 'no_version'
  touch build.properties
  init_with_origin 'no_version_origin'
  run ./release build.properties
  [[ "${output}" =~ VERSION ]]
}
