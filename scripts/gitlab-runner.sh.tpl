#!/bin/bash

echo "Mounting volume"
mkfs.xfs /dev/sda1
mkdir /var/lib/docker
mount /dev/sda1 /var/lib/docker -o noatime

echo "Installing prerequisites of GitLab."
yum -y install git

echo "Install docker."
yum -y install docker
systemctl enable --now docker

echo "Placing docker volume cleanup script."
cat << 'EOF' >> /etc/cron.hourly/docker-prune
#!/bin/sh
# Remove unused volumes to make diskspace available.
docker volume prune --force > /dev/null 2>&1
EOF
chmod 755 /etc/cron.hourly/docker-prune

echo "Instaling gitlab-runner."
rpm -i "https://gitlab-runner-downloads.s3.amazonaws.com/latest/rpm/gitlab-runner_amd64.rpm"

echo "Get information of instance."
my_instance_id="$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)"

echo "Registering gitlab-runner."
gitlab-runner register --non-interactive \
  --name "$${my_instance_id}" \
  --url "${gitlab_runner_url}" \
  --registration-token "${gitlab_runner_registration_token}" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --docker-privileged \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --locked="false" \
  --request-concurrency "${gitlab_runner_concurrency}"

echo "Configuring gitlab-runner."
sed -i "s/concurrent = .*/concurrent = ${gitlab_runner_concurrency}/" /etc/gitlab-runner/config.toml

echo "Starting gitlab-runner."
systemctl enable --now gitlab-runner

echo "Writing the GitLab Runner unregister script."
cat << 'EOF' >> /usr/local/bin/aws_deregister.sh
#!/bin/sh

# Check if we are already running
if [ -f /var/run/aws_deregister.pid ] ; then
  echo "Process already running, exiting"
  exit 1
else
  echo $$ > /var/run/aws_deregister.pid
fi

# If an instance is terminated, unregister the GitLab runner.
if (curl --silent http://169.254.169.254/latest/meta-data/autoscaling/target-lifecycle-state | grep Terminated > /dev/null 2>&1) ; then
  # Tell the gitlab-runner to stop accepting new jobs.
  pkill -SIGQUIT gitlab-runner
  # Wait until there are 0 jobs, or we've retried enough.
  retry_count=0
  until ! pgrep gitlab-runner > /dev/null 2>&1 || [ "\$retry_count" -eq $((${gitlab_runner_cooldown_time}-120)) ] ; do
    sleep 1
    retry_count=$((retry_count+1))
  done
  # Remove the runner from GitLab.
  gitlab-runner unregister --all-runners
fi

rm /var/run/aws_deregister.pid
EOF

echo "Make the ASG deregister script executable."
chmod 754 /usr/local/bin/aws_deregister.sh

echo "Schedule the deregister script every minute."
crontab -l | { cat; echo "* * * * * /usr/local/bin/aws_deregister.sh"; } | crontab -
