---
name: backlog
description: Natural-language entry point for the backlog — say what you want and it runs the proper /backlog:* sub-command.
argument-hint: "['capture dark mode idea', 'show the backlog', 'promote an item']"
tools: Read, Bash, AskUserQuestion
---

# /backlog — Backlog Router

Resolve `$ARGUMENTS` → one backlog sub-command.

The backlog is the project board's draft surface — quick-capture ideas before they become real issues.

## Interpret Intent

Resolve `$ARGUMENTS` → stage + args.

| Your words contain… | Run |
|---|---|
| add / capture / note / idea / jot / remember *(a description)* | `/backlog:add <description>` |
| brainstorm / ideate / suggest features / what should we build | `/brainstorm <description>` |
| list / show / view / what's in the backlog | `/backlog:list` |
| promote / turn into issue / start / work on *(an existing item)* | `/backlog:promote` |

Empty input or unclear stage → ask **one** `AskUserQuestion` for the stage → run resolved command.

Echo before running: `▶ /backlog:<stage> <args>`.
