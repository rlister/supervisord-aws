# supervisord-aws

This is a quick hack of a dashboard for monitoring supervisord on
multiple instances that are part of an AWS AutoScaling group. Since
the instances are likely to change frequently, they need to be
auto-discovered at query time.

## Installation

```sh
git clone https://github.com/rlister/supervisord-aws
```

## Configuration and running

You will need to set credentials for your AWS account and supervisord
instances. All configuration is done with environment variables:

```sh
export AWS_ACCESS_KEY_ID='SEE7OOVAIROOYAEDOHWO'
export AWS_SECRET_ACCESS_KEY='PHaeBeIZ1aiYahbeighuv9aegiushahs/Ij/eighieJoo8'
export REGIONS='us-east-1 us-west-1'
export SUPERVISORD_PORT=9001
export SUPERVISORD_USER=foo
export SUPERVISORD_PASSWORD=s3cr3t

bundle exec foreman start
```

## supervisord setup

This application uses supervisord's RPC interface over HTTP to retrieve
process information, so you will need to ensure it is enabled in your
supervisord config:

```
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[inet_http_server]
port=9001
username=foo
password=s3cr3t

... rest of your config here ...
```

Also ensure that your chosen HTTP port is accessible through the
instance firewalls and security groups.

## Docker

This project comes with a Dockerfile, should that method of deployment
float your boat. Build your own image, or download from docker
registry:

```sh
cat <<EOF > env
AWS_ACCESS_KEY_ID=SEE7OOVAIROOYAEDOHWO
AWS_SECRET_ACCESS_KEY=PHaeBeIZ1aiYahbeighuv9aegiushahs/Ij/eighieJoo8
REGIONS=us-east-1 us-west-1
SUPERVISORD_PORT=9001
SUPERVISORD_USER=foo
SUPERVISORD_PASSWORD=s3cr3t
EOF

docker pull rlister/supervisord-aws
docker run -d --env-file=env -p 9292:9292 rlister/supervisord-aws
```
