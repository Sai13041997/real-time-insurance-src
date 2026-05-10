real-time-insurance-src (Lambda monorepo)
Monorepo for multiple Python AWS Lambda functions (ZIP-per-lambda) with GitHub Actions:

PR: lint-ish sanity checks + package validation
Merge to main: detect changed lambdas, package, deploy via OIDC
Optional: redeploy API Gateway REST API stage (per-environment toggle)
Structure
lambdas/<lambda_name>/src/<lambda_name>/handler.py (your handler)
lambdas/<lambda_name>/requirements.txt (dependencies for that lambda)
config/lambdas.yml maps repo lambda folder -> AWS Lambda function name and handler
config/environments.yml defines dev/prod AWS account/region + optional API Gateway stage deployment info
scripts/ contains packaging + deploy logic shared by workflows
Add a new lambda
Create folder:
lambdas/my_lambda/src/my_lambda/handler.py
lambdas/my_lambda/requirements.txt
Add config entry in config/lambdas.yml:
folder: my_lambda
function_name per environment
handler (e.g. my_lambda.handler.lambda_handler)
Commit + open PR. On merge, only changed lambdas deploy.
Local packaging
make package LAMBDA=example_hello
Environment setup (GitHub)
Use GitHub Environments for dev and prod:

Configure environment protection rules as needed.
Define environment-level secrets/vars if desired.
The workflows assume OIDC is already configured and that you provide:

AWS_ROLE_ARN_DEV and AWS_ROLE_ARN_PROD as GitHub repository secrets
(Optionally) API Gateway IDs/stage names in config/environments.yml
Notes on API Gateway deployments
For Lambda proxy integrations, API Gateway typically does not require redeploy for Lambda code changes. This repo includes an optional redeploy step controlled by config/environments.yml (apigw.redeploy_on_lambda_change). If Terraform manages API Gateway, prefer letting Terraform handle deployments when routes/integrations change.
