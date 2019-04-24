# Quick Guide: Quarkus on Google Cloud Run
In this guide we'll deploy a natively compiled Quarkus application to Google Cloud Run. Here you will:

* Generate a Quarkus application.
* Generate all the configuration necessary to make deployment to Google Cloud Run quick and easy.
* Set up a Cloud Run service and deploy the application.

## Prerequistes
You will need the following:

- [Maven][1] 3.5.3+.
- [Google Cloud CLI][2].
- A [GCP][3] account.

[3]: https://cloud.google.com/
[1]: https://maven.apache.org/download.cgi
[2]: https://cloud.google.com/sdk/

## Setup
Create a simple "greeter" Quarkus application:
```bash
mvn io.quarkus:quarkus-maven-plugin:0.13.3:create \
  -DprojectGroupId=org.acme \
  -DprojectArtifactId=getting-started \
  -DclassName="org.acme.quickstart.GreetingResource" \
  -Dpath="/hello"
```
The greeter service looks like so:
```java
@Path("/hello")
public class GreetingResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "hello";
    }
}
```

Feel free to test and run this locally (see  the [getting started guide][4] for more information). Alternatively, move on to the next step if you just want to get into production fast!

[4]: https://quarkus.io/guides/getting-started-guide

## Prepare for Cloud Run
Cloud Run's container runtime contract states that:
- Executables in the container image must be compiled for Linux 64-bit.
- The container must listen for HTTP requests on `0.0.0.0` on the port defined by the `PORT` environment variable (8080 by default).

To keep billing costs as low as possible, whatever runs inside the container should start fast, execute fast, and utilize as little memory as possible. 

At this point then we should be sure to have an installation of GraalVM and Docker to take care of the native image compilation and containerization parts respectively. However, from a pure development perspective, compiling down our Quarkus application to a native image and containerizing it is we want to avoid. (In addition, GraalVM is not supported on Windows.) Therefore, we're going to delegate this to Google's [Cloud Build][5]. 

[5]: https://cloud.google.com/cloud-build/

The `cloudify-maven-plugin` [maven plugin][6] will help turn your Quarkus application into a Cloud Run ready application.

[6]: https://github.com/quad-teams/cloudify-maven-plugin

Run the plugin like so:

```bash
    mvn -N team.quad:cloudify-maven-plugin:0.1.0:gcloud-run
```

It generates the following:
- A Docker file.
- Google cloud configuration file for building and deploying.
- Scripts to help with the first time setup on Cloud Run.

## Deploy to Cloud Run
The [Cloud Run console][7] (web interface) can be used to set up a Cloud Run project and service. Alternatively, at the root of our project is an interactive `deploy` script, which will guide us through the setup from the command line.

[7]: https://console.cloud.google.com/run

Execute the script and follow the instructions:

```bash
./deploy
```
Or on Windows

```bash
deploy.cmd
```

The script will take you through the process of creating a project and linking your GCP billing account to it. Other tasks such as enabling various APIs, assigning roles to service accounts (for build and deploy permissions) and pushing the code to the cloud are taken care of automatically. Note that native compilation is not a lightweight task so the build step can take several minutes.
