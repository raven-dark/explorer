# RavenDark Docker

## Build

`sudo docker build -t xrd:latest .`

## Run

`sudo docker run -p 80:80 -p 6666:6666 -v ~/data:/xrd-node/data -d --name xrd-insight xrd:latest`

## Watch Logs

`sudo docker logs --tail 100 -f xrd-insight`
