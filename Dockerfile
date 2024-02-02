FROM debian   
WORKDIR / 
COPY denyenv-validating-admission-webhook /denyenv-validating-admission-webhook 
ENTRYPOINT ["/denyenv-validating-admission-webhook"] 

# docker build -t denyenv-validating-admission-webhook:v1 .