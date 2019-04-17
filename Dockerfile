# Step 1: build the native image
FROM oracle/graalvm-ce:1.0.0-rc15 as graalvm
COPY . /home/app
WORKDIR /home/app
ENV GRAALVM_HOME $JAVA_HOME
RUN /home/app/mvnw clean package -Pnative

# Step 2: build the running container
FROM registry.fedoraproject.org/fedora-minimal
WORKDIR /work/
COPY --from=graalvm /home/app/target/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
ENTRYPOINT ["./application", "-Dquarkus.http.host=0.0.0.0"]
