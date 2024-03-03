# Murder CLI

This is a simple CLI for killing processes on Linux.

## Why?

This is for those programs running in the background that you'd otherwise have to hunt down and kill manually. This script is meant to assist you in **murdering** these types of processes for wasting your time digging through `ps` output.

### Features

-   [x] Kill processes by name
-   [x] Kill processes by port with `-p`

## Installation

Installs to your `$HOME/.local/bin` directory.

```bash
git clone https://github.com/xd009642/murder-cli.git
cd murder-cli
./install.sh
```

## Usage

```
Usage: murder [-p] <PROGRAM_NAME | PORT>
```

> [!NOTE]
> I do not use proper option parsing in this script.

### Examples

Kill all processes that are listening on port 8080.

```bash
murder -p 8080
```

Kill all processes that have the word "nginx" in their name.

```bash
murder nginx
```
