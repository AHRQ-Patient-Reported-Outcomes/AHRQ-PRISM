# PRISM Development

## Running the Prism App in Docker: Getting Started
The following will get a development server up and running:

1) Install Docker
2) `docker-compose build`
3) `docker-compose up`


## Running the Prism App in Docker: Testing
```bash
docker-compose build # 1st time only
docker-compose run ruby rspec spec
```

If you're re-recording specs, make sure to get an access token from the Hub and
set environment variable `TEST_HUB_AUTH_TOKEN`.
