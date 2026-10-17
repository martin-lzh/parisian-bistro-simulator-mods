# Release approval records (retired)

Until October 2026, every new version needed a JSON record here that bound the maintainer's instruction to a hash of the release inputs, and CI skipped versions without one.

Releases now follow [releases/README.md](../README.md): merging a PR into `main` is the approval, so CI no longer reads these files. The records in this folder and in `history/` are kept unchanged as a history of past releases. Don't add new ones.
