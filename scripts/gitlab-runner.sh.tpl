#!/bin/bash

echo "Mounting volume"
mkfs /dev/sda1
mkdir /var/lib/docker
mount /dev/sda1 /var/lib/docker

echo "Installing prerequisites of GitLab"
yum -y install git

echo "Install docker"
yum -y install docker
systemctl enable --now docker

echo "Instaling gitlab-runner"
rpm -i "https://gitlab-runner-downloads.s3.amazonaws.com/latest/rpm/gitlab-runner_amd64.rpm"

echo "Get information of instance"
my_instance_id="$(curl http://169.254.169.254/latest/meta-data/instance-id)"

echo "Registering gitlab-runner"
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

sed -i "s/concurrent = .*/concurrent = ${gitlab_runner_concurrency}/" /etc/gitlab-runner/config.toml

echo "Starting gitlab-runner"
systemctl enable --now gitlab-runner

echo "Prepareing GitLab Runner unregister script"
cat << EOF >> /usr/local/bin/aws_deregister.sh
#!/bin/sh

# If an instance is terminated, unregister the GitLab runner.
if (curl --silent http://169.254.169.254/latest/meta-data/autoscaling/target-lifecycle-state | grep Terminated) ; then
  gitlab-runner unregister --all-runners
fi
EOF

echo "Make the AWS Target Group script executable."
chmod 754 /usr/local/bin/aws_deregister.sh

echo "Schedule the deregister script every minute."
crontab -l | { cat; echo "* * * * * /usr/local/bin/aws_deregister.sh"; } | crontab -