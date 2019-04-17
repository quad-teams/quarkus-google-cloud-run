# Deploying Quarkus to Google Cloud Run
A simple Quarkus application ready to be deployed to Google Cloud Run through Google Could Build.

The intention here is to illustrate a push->build->deploy development cycle.


## Create a project
Create a simple project from a Maven archetype:

    mvn io.quarkus:quarkus-maven-plugin:0.13.3:create \
      -DprojectGroupId=org.acme \
      -DprojectArtifactId=getting-started \
      -DclassName="org.acme.quickstart.GreetingResource" \
      -Dpath="/hello"
