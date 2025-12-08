# AWS Static Keys

!!! danger "Not Recommended"
    Using static IAM user access keys is **not recommended** for programmatic access. Whenever possible, prefer temporary credentials using methods like **[AWS OIDC](aws-oidc.md)**. Static keys are long-lived credentials that can pose a significant security risk if compromised.

## Overview

This method involves creating an IAM user with a dedicated set of long-term access keys (`Access Key ID` and `Secret Access Key`). These keys are then configured as environment variables or in a credentials file, which the AWS SDK or CLI uses to authenticate requests.

## Use Cases

Use static keys only when temporary credentials are not a viable option, such as:
- A legacy application that does not support modern authentication flows.
- Specific third-party tools that require long-lived keys.
- Initial setup or bootstrapping scenarios before more secure methods can be configured.

## Configuration

If you must use static keys, configure them as environment variables:

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_REGION=us-east-1
```

## Security Best Practices

- **Principle of Least Privilege**: Grant the IAM user only the permissions it absolutely needs.
- **Key Rotation**: Regularly rotate access keys to limit the window of opportunity for misuse if a key is compromised.
- **Monitoring**: Use AWS CloudTrail to monitor all API calls made with the static keys. Set up alerts for unusual activity.
- **Do Not Hardcode**: Never embed access keys directly in your code. Use environment variables or a secure secrets management tool.
