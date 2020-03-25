#!/usr/bin/env bats

load test_helper

@test 'When untracked files exist, return failure status.' {
  in_test_dir 'untracked'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'untracked_origin'
  touch 'untracked'
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When untracked files exist, output a fitting message.' {
  in_test_dir 'untracked'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'untracked_origin'
  touch 'untracked'
  AUTO_VERSION=true run ./release build.properties
  git status > /buildsrc/build/tmp/status
  [[ "${output}" =~ Untracked ]]
  [[ "${output}" =~ Out\ of\ sync ]]
}

@test 'When not on master, return failure status.' {
  in_test_dir 'nonmaster'
  touch build.properties
  init_with_origin 'nonmaster_origin'
  git checkout -B other
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When not on master, output a fitting message.' {
  in_test_dir 'nonmaster'
  touch build.properties
  init_with_origin 'nonmaster_origin'
  git checkout -B other
  run ./release build.properties
  [[ "${output}" =~ Not\ on\ master ]]
  [[ "${output}" =~ Out\ of\ sync ]]
}

@test 'With unstaged modifications, return failure status.' {
  in_test_dir 'unstaged'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  touch modified
  init_with_origin 'unstaged_origin'
  echo 'updated' > modified
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'With unstaged modifications, output a fitting message.' {
  in_test_dir 'unstaged'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  touch modified
  init_with_origin 'unstaged_origin'
  echo 'updated' > modified
  run ./release build.properties
  [[ "${output}" =~ Modified ]]
  [[ "${output}" =~ Out\ of\ sync ]]
}

@test 'When ahead of master, return failure status.' {
  in_test_dir 'ahead'
  touch build.properties
  init_with_origin 'ahead_origin'
  touch new_file
  git add .
  git commit -m "Added new_file"
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When ahead of master, output a fitting message.' {
  in_test_dir 'ahead'
  touch build.properties
  init_with_origin 'ahead_origin'
  touch new_file
  git add .
  git commit -m "Added new_file"
  run ./release build.properties
  [[ "${output}" =~ ahead\ of\ origin ]]
  [[ "${output}" =~ Out\ of\ sync ]]
}

@test 'When behind master, return failure status.' {
  in_test_dir 'behind'
  touch build.properties
  init_with_origin 'behind_origin'
  touch new_file
  git add .
  git commit -m "Added new_file"
  git push
  git reset --hard HEAD^
  run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When behind master, output a fitting message.' {
  in_test_dir 'behind'
  touch build.properties
  init_with_origin 'behind_origin'
  touch new_file
  git add .
  git commit -m "Added new_file"
  git push
  git reset --hard HEAD^
  run ./release build.properties
  [[ "${output}" =~ behind\ origin ]]
  [[ "${output}" =~ Out\ of\ sync ]]
}
