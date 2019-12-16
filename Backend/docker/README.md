# Running the Prism App in Docker

### Use Cases:
- Run the Ruby backend solo/tests
- Run the Auth Lambda solo/tests
- Run the all services in DEV


## Running Ruby
### Dev server mode
Sometimes we only want to run the ruby lambda code and database and not deal have to have the auth lambda too. 

This code will run the Ruby lambda sinatra app at port 3030 and the dynamoDB container but NOT the Auth lambda
```bash
pwd # ~/PrismApp/PrismAPI

docker-compose build # 1st time only
docker-compose up -d ruby
```

### Testing ruby

```bash
docker-compose build # 1st time only
docker-compose run ruby rspec spec
```

## Auth Lambda
### Run the Auth Lambda server
Sometimes we only want to run the Auth Lambda and database and not deal have to have the ruby code too

This code will run the Auth Express app at port 3000 and the dynamoDB container but NOT the ruby code
```bash
pwd # ~/PrismApp/PrismAPI

docker-compose build # 1st time only
docker-compose up -d auth
```
