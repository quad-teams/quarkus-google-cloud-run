@ECHO off
@SETLOCAL

SET CREATE_PROJECT=true
SET PROJECT_ID=gcp-quarkus
SET SERVICE_NAME=quarkus-google-cloud-run

WHERE /Q gcloud
IF %ERRORLEVEL% NEQ 0 (
    GOTO printInstructions
) else (
    GOTO deploy
)

:createProject
ECHO Setting up %PROJECT_ID%
CALL gcloud projects create --no-user-output-enabled %PROJECT_ID%
CALL gcloud config set project --no-user-output-enabled %PROJECT_ID%
CALL gcloud config set run/region --no-user-output-enabled us-central1
CALL gcloud beta billing accounts list --format="table['box'](displayName,name)"

@REM It reads the account ID
SET /P ACCOUNT_ID="Enter the billing account ID you want to use: "

ECHO Enabling GCP services
CALL gcloud beta billing projects link --no-user-output-enabled %PROJECT_ID% --billing-account=%ACCOUNT_ID%
CALL gcloud services enable --no-user-output-enabled cloudbuild.googleapis.com
CALL gcloud services enable --no-user-output-enabled run.googleapis.com

FOR /F "tokens=*" %%a in ('gcloud beta projects describe %PROJECT_ID% --format="get(projectNumber)"') DO SET PROJECT_NUMBER=%%a
CALL gcloud projects add-iam-policy-binding --no-user-output-enabled %PROJECT_ID% --member serviceAccount:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com --role roles/run.admin
CALL gcloud projects add-iam-policy-binding --no-user-output-enabled %PROJECT_ID% --member serviceAccount:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com --role roles/iam.serviceAccountUser

ECHO Building %SERVICE_NAME%
CALL gcloud builds submit --no-user-output-enabled --config cloudbuild.yaml .
if %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

ECHO You can access your application at:
CALL gcloud.cmd beta run services describe %SERVICE_NAME% --format="get(domain)"
EXIT /B 0

:deployProject
ECHO Building %SERVICE_NAME%
CALL gcloud config set project --no-user-output-enabled %PROJECT_ID%
CALL gcloud builds submit --no-user-output-enabled --config cloudbuild.yaml .
if %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

ECHO You can access your application at:
CALL gcloud.cmd beta run services describe %SERVICE_NAME% --format="get(domain)"
EXIT /B 0

:deploy
IF "%CREATE_PROJECT%" == "true" (
    GOTO createProject
) ELSE (
    GOTO deployProject
)

:printInstructions
ECHO ========================================================================
ECHO In order to deploy this project, you need gcloud set in your PATH.
ECHO You can download it from https://cloud.google.com/sdk
ECHO ========================================================================
EXIT /B 0
