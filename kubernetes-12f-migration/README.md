# Migrating 12 factor applications to Kubernetes

The purpose of this workshop is to introduce students to migrating and deploying 12 factor applications to a Kubernetes cluster. It contains hands on examples of containerizing apps, developing locally using Docker, packaging them and deploying them to Kubernetes.

## Duration

The duration of this training is 8 hours (full-day).

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

* The art of continuous integration with Docker
* Continuous delivery
* Quick intro to Drone CI
* Exercise: setting up a Ruby microservice with Sinatra
* Exercise: setting up a Python microservice with Flask, which needs static assets built with Node.js
* Exercise: setting up a Python microservice with Django, which connects to the other two services and needs migrations
* Bonus: exposing the Django microservice to the world with Ceryx
* Case study: from monoliths to a containerized infrastructure
