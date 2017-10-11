# docker-cmd

Check docker IP

```
docker inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress }}' $(docker ps -aq)
```

Run docker iteractively 

```
docker run -v /N0S1/nfs/:/workspace -ti novucaffe
```

