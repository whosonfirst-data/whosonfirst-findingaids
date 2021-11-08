# whosonfirst-findingaids

Finding aids for mapping Who's On First IDs to their corresponding `whosonfirst-data` repository.

## Important

This is work in progress and still considered experimental. For background please see:

## Venues

Venue-specific finding aids are maintained in the [whosonfirst-findingaids-venue](https://github.com/whosonfirst-data/whosonfirst-findingaids-venue) repository.

* https://github.com/whosonfirst-data/whosonfirst-data/discussions/1967

## AWS

### IAM

#### Policies

##### Parameter Store (AWS Systems Manager)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:{REGION}:{ACCOUNT}:parameter/{NAME}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:{REGION}:{ACCOUNT}:key/CMK"
            ]
        }
    ]
}
```

## See also

* https://github.com/whosonfirst/go-whosonfirst-findingaids
* https://github.com/whosonfirst/go-reader-findingaid
