# Borg Backup

## Environment Variables

Set these to avoid specifying the repo path and passphrase on every command:

```bash
export BORG_REPO=/path/to/repo
export BORG_PASSPHRASE='your-passphrase'
```

## Listing Archives and Files

```bash
# List all archives in the repo
borg list

# List files in a specific archive
borg list ::archive-name

# With more details (size, permissions, dates)
borg list --format "{mode} {user:8} {size:10} {mtime} {path}{NL}" ::archive-name
```

## Interactive Browsing

Mount an archive to browse files directly:

```bash
borg mount ::archive-name /mnt/borg
ls /mnt/borg

# When done
borg umount /mnt/borg
```

## Verification

```bash
# Verify archive can be extracted (dry run, no files written)
borg extract --dry-run ::archive-name

# Check repository integrity
borg check
```
