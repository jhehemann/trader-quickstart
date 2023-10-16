#!/bin/bash

cd trader
poetry install
poetry run autonomy packages sync

service_dir="trader_service"
build_dir="abci_build"
directory="$service_dir/$build_dir"

if [ -d $directory ]
then
    echo "Detected an existing build. Using this one..."
    cd $service_dir

    if rm -rf "$build_dir"; then
        echo "Directory "$build_dir" removed successfully."
    else
        # If the above command fails, use sudo to remove
        echo "You will need to provide sudo password in order for the script to delete part of the build artifacts."
        sudo rm -rf "$build_dir"
        echo "Directory "$build_dir" removed successfully."
    fi
else
    echo "Setting up the service..."

    if ! [ -d "$service_dir" ]; then
        # Fetch the service
        poetry run autonomy fetch --local --service valory/trader --alias $service_dir
    fi  
    
fi

cd $service_dir
poetry run autonomy build-image --dev
cp ../../.trader_runner/keys.json keys.json 

poetry run autonomy deploy build keys.json --dev --packages-dir ~/coding/pm_agents/trader-quickstart/trader/packages --open-autonomy-dir ~/coding/pm_agents/open-autonomy --open-aea-dir ~/coding/pm_agents/open-aea/ --n 1 --use-hardhat -ltm

cd ..

poetry run autonomy deploy run --build-dir trader_service/abci_build --detach

cd ..
