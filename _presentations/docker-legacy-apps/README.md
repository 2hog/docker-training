# Migrating legacy applications to containers

The purpose of this workshop is to introduce students to migrating and deploying legacy applications to a containerized cluster. It contains hands on examples of containerizing apps, developing locally using Docker, packaging them and deploying them.

## Duration

The duration of this training is 4 hours (half-day).

## Topics covered

After the end of the training, participants should be able to understand:

* Understand the need for a CI/CD system to back the development process
* Different use cases for building Docker images
* Setting up Docker Compose config files for local development
* Using auto-reloading servers for local development
* Creating multi-stage builds, to build static assets
* Run things like static assets deployment and migrations during CI deployment

## Agenda

Below is a typical agenda for this training

* The DevOps dream
* Efficient Docker images
* Exercise: setting up a Ruby microservice with Sinatra
* Exercise: setting up a Python microservice with Django, which connects to the other two services and needs migrations
* Exercise: setting up a PHP microservice with Slim
* Case study: from monoliths to a fully-containerized infrastructure
