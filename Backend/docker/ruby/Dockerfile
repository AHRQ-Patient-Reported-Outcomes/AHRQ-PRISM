# Tutorials used to get here:
# - https://medium.com/@cristian_rivera/cache-rails-bundle-w-docker-compose-45512d952c2d
# - https://auth0.com/blog/ruby-on-rails-killer-workflow-with-docker-part-1/
FROM ruby:2.5.5

RUN apt-get update && apt-get install -y build-essential && gem install bundler

RUN mkdir /api
WORKDIR /api

COPY ./api/Gemfile* /api/

RUN bundle install --deployment --without development:test

COPY ./api /api

COPY ./docker/ruby/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
