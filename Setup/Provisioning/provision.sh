#!/bin/bash
source .env

tofu apply -auto-approve

tofu output -raw ansible_inventory > ../Configuration/inventory/production.ini
