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
