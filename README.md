# README

This README documents the steps necessary to get the application up and running.

## Ruby Version
* 3.3.6

## System Dependencies
* Docker Compose for Development

## Database Creation and Initialization
```bash
bundle exec web rails db:setup
```

## Development Environment
This project uses Docker for the development environment. To set up the environment, run:

```bash
docker-compose up
```

## Running Tests
To run the test suite, use the following command:

```bash
docker-compose run web bundle exec rspec
```

## Tech Decisions
<!-- Describe the technical decisions made during the development of this project. -->

## Deployment Instructions
Instructions for deploying the application.
