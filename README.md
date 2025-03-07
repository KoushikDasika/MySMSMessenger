# README

This README documents the steps necessary to get the application up and running.

## Versions
* Ruby 3.4.2
* Ruby on Rails 8.0.1
* Mongo 8
* Angular 19
* NodeJS 22

## System Dependencies
* Docker Compose for Development

## Database Creation and Initialization
```bash
./my_sms_messenger.sh run rails db:setup
./my_sms_messenger.sh run rails db:test:prepare
```

## Development Environment
This project uses Docker for the development environment. To set up the environment, 
You will need to put the key files `(development.key, test.key, production.key)` in the api/config/credentials folder in order for the server to work. Then run:

```bash
docker-compose up
```


## Helper Script Usage
This project includes a helper script (`my_sms_messenger.sh`) that simplifies common development tasks. Make the script executable with `chmod +x my_sms_messenger.sh` and use it as follows:

### Backend Commands
```bash

# Run tests (with optional path arguments)
./my_sms_messenger.sh rspec [path]

# Open a bash shell in the API container
./my_sms_messenger.sh bash

# Run any command in the API container
./my_sms_messenger.sh run [command]
```

### Frontend Commands
```bash
# Run a command in the frontend container
./my_sms_messenger.sh run-frontend [command]

# Open a bash shell in the frontend container
./my_sms_messenger.sh run-frontend npm run test
```

### General Commands
```bash
# Restart containers
./my_sms_messenger.sh restart [container_name]
```

## Running Tests
To run the test suite, use the following command:

```bash
./my_sms_messenger.sh rspec
./my_sms_messenger.sh bash-frontend 
```

## Tech Decisions
### Architecture
- **Microservices Architecture**: The application is split into separate backend (Rails API) and frontend (Angular) services, each with its own container.
I split the frontend and backend into two separate projects in two folders so that they are not coupled in development. That way we can let them shine with their strengths and toolchains without worrying about cross framework integration issues. They can be deployed and worked on separately.  However, this does not prevent them from being delivered together in one container in production.  If the app stays a SPA, we can have the Angular code be built into bundled files that are served from the Rails public folder. However, this approach does not allow for SSR or if you wanted to combine AngularJS with Hotwire.

### Backend (Rails API)
- **Context-based Organization**: Non-standard Rails directory structure with a `contexts` folder that organizes code by domain rather than by technical function, following a more domain-driven design approach.
This is a way to minimize complexity and keep the code more modular.
- **Twilio Integration**: Uses the Twilio API for SMS messaging functionality.
I keep API services in a separate folder from other business logic services. Apis, libraries, gems all change over time. This way we can deal with api library upgrades without changing our business logic too much as long as the output is the same. For example, Shopify hard deprecated their REST api and shifted entirely to their GraphQL endpoint. This turned out to be a super safe upgrade. Typically, we would use libraries to handle this abstraction, but even libraries decay due to maintainers stopping work on them so this just makes them follow an Adapter pattern.
- **RSpec Testing**: Uses RSpec for testing instead of the default Rails MiniTest.
- **Response Objects**: Custom response objects (like `SendMessageResponse`) instead of using Rails' built-in response handling.  I know that Ruby is moving towards strong typing with the likes of Sorbet or Tapioca, but this is using built in Ruby items.

### Frontend (Angular)
- **TailwindCSS**: Implements TailwindCSS for styling. I'm not strong at CSS so Tailwind is nice for me.
- **TypeScript**: Fully typed codebase with TypeScript.
- **Karma/Jasmine**: Uses Karma and Jasmine for frontend testing.

## Next Steps
- Rather than have the user wait synchronously for the Twilio API, we could enqueue a background job with retries for the message. We would add a status to the message object. Initial sending will be pending.  When the API call in the job succeeds, the status can change to Sent.  Finally, when the acknowledgement comes in from the Twilio Webhook, the message can be updated with the status Delivered. There should be timestamp attributes for all of them.  This is also for managing api rate limits because we can control the api calls
- Websocket or long polling connection with the api for messages so that the chat is more interactive. Potentially do a pubsub model if its a group chat with multiple users. Easy to implement presence features too if theres a channel.

## Deployment Instructions
Instructions for deploying the application.
