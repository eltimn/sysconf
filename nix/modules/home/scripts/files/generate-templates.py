#!/usr/bin/env python3
"""
Generate JSON file with nix flake templates from various sources.
Sources are defined in the init-new-project skill.
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from urllib.error import HTTPError
from urllib.request import urlopen


@dataclass
class Template:
    """Represents a single flake template."""

    name: str
    ref: str
    description: str
    source: str


@dataclass
class Source:
    """Represents a template source."""

    name: str
    url: str
    type: str
    owner: str
    repo: str


# Sources from init-new-project skill (in priority order)
SOURCES = [
    Source(
        "github:eltimn/sysconf",
        "https://raw.githubusercontent.com/eltimn/sysconf/main/flake.nix",
        "github",
        "eltimn",
        "sysconf",
    ),
    Source(
        "github:NixOS/templates",
        "https://raw.githubusercontent.com/NixOS/templates/master/flake.nix",
        "github",
        "NixOS",
        "templates",
    ),
    Source(
        "github:akirak/flake-templates",
        "https://raw.githubusercontent.com/akirak/flake-templates/master/flake.nix",
        "github",
        "akirak",
        "flake-templates",
    ),
    Source(
        "github:the-nix-way/dev-templates",
        "https://raw.githubusercontent.com/the-nix-way/dev-templates/main/flake.nix",
        "flakehub",
        "the-nix-way",
        "dev-templates",
    ),
]


def fetch_flake(url: str, timeout: int = 30) -> Optional[str]:
    """Fetch flake.nix content from URL with timeout."""
    try:
        with urlopen(url, timeout=timeout) as response:
            if response.status == 200:
                return response.read().decode("utf-8")
            print(f"    HTTP {response.status} from {url}", file=sys.stderr)
            return None
    except HTTPError as e:
        print(f"    HTTP {e.code} from {url}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"    Error fetching {url}: {e}", file=sys.stderr)
        return None


def extract_templates_section(content: str) -> Optional[str]:
    """Extract templates section from flake.nix content using brace counting."""
    lines = content.split("\n")
    in_templates = False
    brace_count = 0
    output_lines = []

    for line in lines:
        # Check for templates = { or templates = rec {
        if not in_templates:
            if re.search(r"templates\s*=\s*(rec\s+)?\{", line):
                in_templates = True
                brace_count = 1
                continue

        if in_templates:
            # Count braces (outside of strings)
            open_braces = count_braces_outside_strings(line, "{")
            close_braces = count_braces_outside_strings(line, "}")
            brace_count += open_braces - close_braces

            # If we're back to 0, we've closed the templates section
            if brace_count == 0:
                break

            output_lines.append(line)

    return "\n".join(output_lines) if output_lines else None


def count_braces_outside_strings(line: str, brace: str) -> int:
    """Count braces that are outside of strings."""
    count = 0
    in_string = False
    string_char = None
    i = 0
    while i < len(line):
        char = line[i]

        # Handle string start/end
        if char in ('"', "'") and not in_string:
            in_string = True
            string_char = char
        elif char == string_char and in_string:
            # Check for escaped quotes
            if i > 0 and line[i - 1] != "\\":
                in_string = False
                string_char = None

        # Count braces only outside strings
        elif char == brace and not in_string:
            count += 1

        i += 1

    return count


def extract_description(line: str) -> Optional[str]:
    """Extract description from a line."""
    match = re.search(r'description\s*=\s*"([^"]*)"', line)
    if match:
        return match.group(1)
    return None


def parse_templates(content: str, source: Source) -> list[Template]:
    """Parse templates from flake.nix content."""
    templates = []
    templates_section = extract_templates_section(content)

    if not templates_section:
        return templates

    lines = templates_section.split("\n")
    in_template = False
    template_name = ""
    description = ""
    template_brace_count = 0

    for line in lines:
        stripped = line.strip()

        # Skip empty lines and comments
        if not stripped or stripped.startswith("#"):
            continue

        # Check for template name start (e.g., "basic = {")
        if not in_template:
            match = re.match(r"^\s*([a-zA-Z0-9_-]+)\s*=\s*\{", stripped)
            if match:
                template_name = match.group(1)
                # Skip if it's an alias like "default = basic;"
                if stripped.rstrip().endswith("{"):
                    in_template = True
                    template_brace_count = 1
                    description = ""
            continue

        if in_template:
            # Count braces outside strings
            open_braces = count_braces_outside_strings(line, "{")
            close_braces = count_braces_outside_strings(line, "}")
            template_brace_count += open_braces - close_braces

            # Extract description
            desc = extract_description(line)
            if desc:
                description = desc

            # End of template (brace count returns to 0)
            if template_brace_count == 0:
                if template_name and description:
                    if source.type == "flakehub":
                        ref = f"https://flakehub.com/f/{source.owner}/{source.repo}/0.1#{template_name}"
                    else:
                        ref = f"github:{source.owner}/{source.repo}#{template_name}"

                    templates.append(
                        Template(
                            name=template_name,
                            ref=ref,
                            description=description,
                            source=source.name,
                        )
                    )

                in_template = False
                template_name = ""
                description = ""

    return templates


def generate_json(output_file: Path, force: bool = False) -> bool:
    """Generate JSON file with templates from all sources."""
    if output_file.exists() and not force:
        print(f"{output_file} already exists. Use -f to force update.", file=sys.stderr)
        return True

    print("Fetching templates from sources...", file=sys.stderr)

    all_templates: list[Template] = []

    for source in SOURCES:
        print(f"  Fetching from {source.name}...", file=sys.stderr)

        content = fetch_flake(source.url)

        if content is None:
            print("    Failed to fetch templates", file=sys.stderr)
            continue

        templates = parse_templates(content, source)

        if templates:
            print(f"    Found {len(templates)} templates", file=sys.stderr)
            all_templates.extend(templates)
        else:
            print("    No templates found", file=sys.stderr)

    if not all_templates:
        print("No templates found!", file=sys.stderr)
        return False

    # Sort templates by source, then by name
    all_templates.sort(key=lambda t: (t.source, t.name))

    # Build JSON structure
    templates_json = [
        {
            "name": t.name,
            "ref": t.ref,
            "description": t.description,
            "source": t.source,
        }
        for t in all_templates
    ]

    data = {
        "templates": templates_json,
        "metadata": {
            "total_count": len(all_templates),
            "sources": [s.name for s in SOURCES],
            "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
    }

    # Write JSON file
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w") as f:
        json.dump(data, f, indent=2)

    print(
        f"Generated {output_file} with {len(all_templates)} templates", file=sys.stderr
    )
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Generate JSON file with nix flake templates from various sources"
    )
    parser.add_argument(
        "output",
        nargs="?",
        type=Path,
        help="Output file path (default: nix-templates.json in script directory)",
    )
    parser.add_argument(
        "-f", "--force", action="store_true", help="Force update even if file exists"
    )
    parser.add_argument(
        "-o", "--output", dest="output_flag", type=Path, help="Output file path"
    )

    args = parser.parse_args()

    # Determine output file
    output_file = args.output_flag or args.output
    if not output_file:
        script_dir = Path(__file__).parent
        output_file = script_dir / "nix-templates.json"

    success = generate_json(output_file, force=args.force)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
