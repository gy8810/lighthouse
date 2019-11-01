#!/bin/bash

# This script is assumed to be run from the LH_ROOT directory.

gcloud compute instances create lantern-collect-instance \
  --image-family=ubuntu-1804-lts --image-project=ubuntu-os-cloud \
  --zone=us-central1-a \
  --boot-disk-size=100GB \
  --machine-type=n1-standard-2

echo "export WPT_KEY=\"$WPT_KEY\"" > .tmp_wpt_key
gcloud compute scp ./.tmp_wpt_key lantern-collect-instance:/tmp/wpt-key
rm .tmp_wpt_key

gcloud compute scp ./lighthouse-core/scripts/lantern/collect/gcp-setup.sh lantern-collect-instance:/tmp/gcp-setup.sh
gcloud compute scp ./lighthouse-core/scripts/lantern/collect/gcp-run.sh lantern-collect-instance:/tmp/gcp-run.sh
gcloud compute ssh lantern-collect-instance --command="bash /tmp/gcp-setup.sh"
gcloud compute ssh lantern-collect-instance --command="sudo -u lighthouse screen -d -m -L /home/lighthouse/screen.log -S collect /home/lighthouse/gcp-run.sh"

echo "Collection job started!"
echo "Check-in on progress anytime by running..."
echo "  $ gcloud compute ssh lantern-collect-instance"
echo "  $ sudo -u lighthouse screen -r collect"
echo "(Exit the log without quitting by pressing 'ctrl+a' then 'd')"

echo "When complete run..."
echo "  $ gcloud compute scp lantern-collect-instance:/home/lighthouse/src/lighthouse/dist/collect-lantern-traces.zip ./collect-lantern-traces.zip"
echo "  $ gcloud compute instances delete lantern-collect-instance"
