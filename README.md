# s3-multibranch-deploy-preview

## Intro

This is simple composite Github Action that is designed to deploy previews of branches to single Amazon S3 bucket, enabling multi-branch deployment workflows with logrotate of stale versions and easily managed CI\CD for your fronted projects. This action enables you to deploy multiple versions of your site, with each version corresponding to a different branch in your repository. It ensures that the latest commits are deployed, allowing you to track changes and compare different versions seamlessly.

## Key concepts

This action was build on top of:
* [configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) action
* [AWS S3 Javascript explorer](https://github.com/awslabs/aws-js-s3-explorer)
* Recommended [cloudformation](https://github.com/aws-samples/amazon-cloudfront-secure-static-site) for static web site deployment

If you are building or planning to build your website and CI/CD process using the listed technologies, this action can significantly automate the deployment of your previews.

The action allows you to deploy your site's content per branch, commit, or pull request in a hierarchical structure and generate a preview link in the format http://{bucketOrigin}/{branchName}/{commitHash}/your.html.

This application uses its configuration file .branches to track the automatically uploaded content.

For convenience and usability, it is recommended to use AWS S3 Explorer in your test bucket, which allows you to navigate the bucket's content, search for the necessary branches and commits, and view specific deployed versions.

The file structure in the Amazon interfaces and the S3 JavaScript explorer is shown below.

![image](https://github.com/user-attachments/assets/e7b4b1cd-f81d-49c0-9f7b-fa78dd8b34d1)

![image](https://github.com/user-attachments/assets/03df68ab-f16e-40a4-af22-5e655dc600bc)

![image](https://github.com/user-attachments/assets/0caa4e8e-f143-4a08-b21c-2b8bbda62634)

## How to use

Current examples of usage could be found for:
* [mkdocs site](https://github.com/dyadyaJora/pandas_challenge/blob/test-my-action/.github/workflows/test-my-action.yml#L38)
* [docusaurus site](https://github.com/dyadyaJora/demo-docusaurus-multibranch-deploy/blob/master/.github/workflows/build-deploy.yml#L40)

## Options
### Input Parameters

| Parameter Name                   | Example Values          | Detailed Description                                                                 |
|----------------------------------|-------------------------|--------------------------------------------------------------------------------------|
| `aws_region`                     | `us-east-1`             | AWS region where the S3 bucket is located. Default is `us-east-1`.                   |
| `aws_assume_role`                | `arn:aws:iam::123456789012:role/example-role` | ARN of the role to be assumed for AWS operations.                                    |
| `aws_bucket`                     | `my-s3-bucket`          | Name of the S3 bucket where the site will be deployed.                               |
| `folder`                         | `./site`                | Folder containing the static site files to be deployed to the S3 bucket.             |
| `max_branch_deployed`            | `50`                    | Maximum number of branches to be deployed. Default is `50`.                          |
| `max_commit_per_branch_deployed` | `10`                    | Maximum number of commits per branch to be deployed. Default is `10`.                |
| `prefix`                         | `my-prefix`             | Prefix path for the base URL of the deployed site.                                   |
| `generate_prefix`                | `true`                  | Whether to generate a prefix for each branch. Default is `false`.                    |

### Output Parameters

| Parameter Name | Example Values                | Detailed Description                                                                 |
|----------------|-------------------------------|--------------------------------------------------------------------------------------|
| `preview_url`  | `https://my-s3-bucket.s3.amazonaws.com/branch/index.html` | URL of the deployed preview.                                                         |
| `prefix`       | `branch-name`                 | Generated prefix for the deployed branch.                                            |
