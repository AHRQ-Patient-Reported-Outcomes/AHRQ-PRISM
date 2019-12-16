# The PRISM App Backend Services
The PRISM Backend consists of a number of AWS services and 2 lambda functions. The primary lambda function is written in ruby and functions as the primary API for the frontend. This is found in the `./api` folder. The other lambda function is call the Auth Lambda and servers to facilitate the OAuth/SMART on FHIR handshake between the PRISM app, the Identity Server and AWS Cognito. It is found in `./auth`. 

### Key Documents
Please read the following documents to understand how to build and run the PRISM Backend in development and production
- [./docs/install-dependencies.md](docs/install-dependencies.md) follow this to learn about the things you need to install before being able to develop or deploy
- [./docs/how-to-deploy.md](docs/how-to-deploy.md) follow this to get your own version of PRISM up and running
- [./docs/run-for-development.md](docs/run-for-development.md) follow this to build and test for development
