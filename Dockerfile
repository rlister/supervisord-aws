FROM rlister/ruby:2.1.5
MAINTAINER Ric Lister, ric@spreecommerce.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    build-essential zlib1g-dev libreadline6-dev libyaml-dev libssl-dev \
    ca-certificates

## help docker cache bundle
WORKDIR /tmp
ADD ./Gemfile /tmp/
ADD ./Gemfile.lock /tmp/
RUN bundle install
RUN rm -f /tmp/Gemfile /tmp/Gemfile.lock

WORKDIR /app
ADD ./ /app

EXPOSE 9292

ENTRYPOINT [ "bundle", "exec" ]
CMD [ "foreman", "start" ]
