FROM ruby:3.1.2

WORKDIR /usr/src/app

ARG RAILS_MASTER_KEY
ARG PROJECT_ROOT


ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

COPY $PROJECT_ROOT/ /usr/src/app
RUN gem install bundler
RUN bundle config set --local without 'test'
RUN bundle config --global frozen 1
RUN bundle install
#
#
# RUN bundle exec rake assets:precompile
#
# CMD ["bundle", "exec", "puma"]
