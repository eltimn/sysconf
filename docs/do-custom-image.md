# Digital Ocean Custom Image Creation

This document outlines the process for creating and deploying a custom NixOS image for Digital Ocean.

## Prerequisites

- NixOS development environment
- Digital Ocean account with Spaces access

## Build Process

### 1. Build the Custom Image

Use the Taskfile to build the Digital Ocean image:

```bash
task build-do-image
```

This will create a compressed qcow2 image at:
```
./result/nixos-image-digital-ocean-25.11.20251223.76701a1-x86_64-linux.qcow2.gz
```

### 2. Upload to Spaces

#### Option A: Manual Upload (Recommended)

1. Access your Digital Ocean Spaces bucket via the web interface
2. Upload the image file from `./result/`
3. Set the file to be publicly accessible
4. Note the public URL

#### Option B: Using s3cmd (if configured)

```bash
s3cmd --access_key=$AWS_ACCESS_KEY_ID \
      --secret_key=$AWS_SECRET_ACCESS_KEY \
      --host=nyc3.digitaloceanspaces.com \
      put ./result/nixos-image-digital-ocean-25.11.20251223.76701a1-x86_64-linux.qcow2.gz \
      s3://sysconf-images/nixos-25.11-v3.qcow2.gz \
      --acl-public
```

### 3. Create Digital Ocean Custom Image

Use OpenTofu to create the custom image and test VPS.

```bash
cd infra
tofu apply
```

This will:
- Upload the image to Spaces (configured in TF)
- Create a Digital Ocean custom image from the uploaded file

### 4. Deploy with OpenTofu

1. Reference the custom image ID in your Terraform/OpenTofu configuration
2. Create droplets using the custom image
3. Configure with Colmena for ongoing management

## Configuration Details

### Image Features

The custom NixOS image includes:
- SSH access for both `sysconf` and `nelly` users
- Essential packages: vim, git, htop, curl, wget
- Flakes and nix-command enabled
- Custom DO marketplace base configuration

### File Locations

- Configuration: `nix/machines/do-image/configuration.nix`
- Flakes definition: `flake.nix`
- Build tasks: `Taskfile.yml`

## Version Management

When updating the image:
1. Increment version in the filename (v1, v2, v3, etc.)
2. Update the Spaces URL accordingly
3. Create new DO custom image with incremented version
4. Update OpenTofu configurations to use new image ID

## Cleanup

After successful deployment, clean up build artifacts:

```bash
task clean
```

This removes the `result/` directory containing the built image.
