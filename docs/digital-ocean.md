# Digital Ocean

OpenTofu uses the following environment variables (see envrc):

* `TF_VAR_do_access_token` for main access.
* `SPACES_ACCESS_KEY_ID` and `SPACES_SECRET_ACCESS_KEY` for Spaces access.

OpenTofu uses the `AWS_*` environment variables for the tfstate backend.

## s3

It was easier to use s3cmd by creating a credentials file using
`s3cmd --configure -c ~/secret/sysconf/digital-ocean/s3-bucket-creds`

ref: [Set Up s3cmd 2.x with DigitalOcean Spaces](https://docs.digitalocean.com/products/spaces/reference/s3cmd/)

Use `s3-images-creds` for read/write access to the sysconf-images bucket.
Use `s3-full-creds` for full access to Spaces commands.

## doctl

The "auth context" name should match the Personal access token name.

```bash
doctl auth list # shows the current contexts configured

# init and switch
doctl auth remove --context ops
doctl auth init --context ops
doctl auth switch --context ops

# misc commands
doctl account get
doctl compute ssh-key list # gets the list of ssh keys
```
