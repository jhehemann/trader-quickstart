#!/bin/bash
# Abort on first error in the script
set -e

# Step 1: Navigate to ./trader repo and run specific poetry commands
cd ../trader || { echo "Failed to cd into ../trader. Exiting."; exit 1; }
poetry run autonomy packages lock
poetry run autonomy push-all

# Step 2: Add and commit all changes
read -p "Enter your commit message: " commit_message
git add .
git commit -m "$commit_message"
git push

# Step 3: Navigate to trader-quickstart and check for ./trader repo
cd ../trader-quickstart || { echo "Failed to cd into ../trader-quickstart. Exiting."; exit 1; }
if [ -d "./trader" ]; then
  rm -rf ./trader
else
  echo "./trader does not exist. Continuing."
fi

# Step 4: Execute the shell script ./run_service.sh
./run_service.sh || { echo "Failed to run ./run_service.sh. Exiting."; exit 1; }
