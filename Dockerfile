FROM ubuntu:14.04

#Update the system
RUN apt-get update && apt-get install -y
RUN apt-get install -y build-essential ruby1.9.1-dev
RUN apt-get install -y nodejs

# Install dashing and bundle
RUN gem install dashing
RUN gem install bundle

# for dashing
EXPOSE 9292
# for ssh
EXPOSE 22

COPY ./dashboard /dashboard

CMD ["bash", "dashboard/start.sh"]
