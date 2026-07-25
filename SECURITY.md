# Security Policy

## Scope

ConnectHub is an **offline demo application** with no real backend, no user accounts, and no network calls — every service is a local fake backed by bundled JSON. There is no server to attack and no real user data at rest beyond on-device demo state (`UserDefaults` preferences and a local SwiftData cache).

As such, the security surface is limited. Still, we welcome reports of anything that could mislead users of the codebase (for example, a sample that models an insecure pattern as if it were production-ready).

## Reporting a vulnerability

If you find a security-relevant issue:

1. **Do not** open a public issue for anything you believe is sensitive.
2. Email the maintainer or open a private security advisory on the repository.
3. Include steps to reproduce and the affected file(s).

We aim to acknowledge reports within a few days.

## Notes for readers

Because this is a learning project, a few deliberate simplifications are **not** production-grade and are called out in the docs:

- The session token is a locally generated string stored in `UserDefaults` (a real app would use the Keychain — the `SessionStore` seam isolates this).
- Authentication is faked; no credentials are validated against a server.
- Chat messages live in an in-memory actor for the session (durable persistence is a documented future improvement).
