# Template Platform

**Template Platform** is a foundational backend service designed to provide a ready-to-use, scalable, and maintainable starting point for new applications. It integrates seamlessly with the infrastructure components provided by `infra-core` and `infra-template`, and its deployment is managed by pipelines from `infra-ci`.

## Core Purpose

The primary goal of `template-platform` is to accelerate development by offering a pre-configured environment that includes:

- **API Scaffolding**: A basic structure for creating RESTful or GraphQL APIs.
- **Database Integration**: Pre-configured connections to standard databases.
- **CI/CD Integration**: Ready to be deployed to `dev` and `stage` environments out-of-the-box using `infra-ci`.
- **Observability**: Hooks for logging, metrics, and tracing.

## Getting Started

To begin working with `template-platform`, ensure you have cloned the repository and initialized its submodules:

```bash
git clone <your-repo-url>/template-platform.git
cd template-platform
git submodule update --init --recursive
```

The service can be run locally using Docker Compose:

```bash
docker-compose up --build
```

## Deployment

Deployments are handled automatically by GitHub Actions upon pushing to the `main` branch (for the `dev` environment) or can be triggered manually (for the `stage` environment). The pipeline uses Terraform configurations defined within the `template-platform` repository, which in turn utilize modules from `infra-template`.
