#!/bin/bash

BASE=/tmp/submodules
PUB=${BASE}/public
PR1=${BASE}/private1
PR2=${BASE}/private2


APP_URL=${PUB}/app.git
LIB1_URL=${PUB}/lib1.git
LIB2_URL=${PUB}/lib2.git


commit() {
  FILE=$RANDOM
  echo "Commit in $(pwd)"
  echo ${FILE} >> file-${1}.txt
  git add file-${1}.txt
  echo -e "\033[6mCommit...\033[0m"
  git commit -m"${2}"
}

pause() {
  echo "-----------------------------------------------"
  echo ${1}
  echo "-----------------------------------------------"
  read
}

run() {
  echo
  echo -e "CMD> \033[1m${1}\033[0m"
  ${1}
}

# Remove and re-create folders
mkdir -p ${BASE}
cd ${BASE}
pause "Removing folders in $(pwd)"
rm -rf public private1 private2
mkdir public private1  private2


cd ${PUB}
pause "Init public bare repos"
for i in app lib1 lib2; do
  run "git init --bare ${i}.git"
done

pause "Clone repos and add changes"
cd ${PR1}
for i in app lib1 lib2; do
  pause "--- ${i}"
  run "git clone ${PUB}/${i}.git"
  cd ${i}
  commit ${i} "Commit 1 in ${i}"; commit ${i} "Second commit in ${i}"
  run "git push origin master"
  cd ${PR1} 
done

pause "Adding more commits to app"
cd ${PR1}/app
commit app "Some change in app"
commit app "Another change in app"
run "git push origin master"

pause "Adding submodule lib1"
run "git submodule add ${LIB1_URL} x_lib1"

run "git status"

pause "Commit and push changes to server"
run "git ci -mAdding_lib1_submodule"
run "git push origin master"


pause "Changing to second WC and cloning"
cd ${PR2}
run "git clone ${APP_URL}"
cd app
run "ls -las"
run "ls x_lib1"
run "git status"

pause "Init submodules"
run "git submodule init"
echo "x_lib1 is still empty"
run "ls x_lib1"
pause "git submodule update"
run "git submodule update"
run "ls -las x_lib1"
run "git ls"
run "cd x_lib1"
run "git ls"

pause "Let's add some changes to x_lib1"
commit lib1 "Adding a change from $(pwd)"
run "git status"
run "git ls"
run "git push origin master"

pause "What's the status of app?"
cd ..
pwd
run "git status"



