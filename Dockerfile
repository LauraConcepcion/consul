FROM ruby:2.3.2

## In case of postgresql for heroku:
# RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/postgeresql.list \
#  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
#  && apt-get update                                     \
#  && apt-get update                                     \
#  && apt-get install -y --no-install-recommends         \
#    postgresql-client-9.6 pv ack-grep ccze unp htop vim \
#  && rm -rf /var/lib/apt/lists/*                        \
#  && apt-get purge -y --auto-remove

## In case of mysql for amazon RDS
RUN apt-get update                                                     \
  && apt-get update                                                    \
  && apt-get install -y --no-install-recommends mysql-client nodejs pv \
  && rm -rf /var/lib/apt/lists/*                                       \
  && apt-get purge -y --auto-remove

ENV BUNDLER_VERSION 1.15.4

RUN gem install bundler --version "$BUNDLER_VERSION"

WORKDIR /usr/src/app

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
