# First run

This is a new short setup walkthrough. It is not the absent twenty-module companion post.

1. Complete README setup and add the hosts entry on the browser computer.
2. Run `make smoke`. It checks the initial seed, app, bucket index, metadata mock, attacker script and MailHog API.
3. Open `http://vibeshop.test:8080/`, inspect a product and use its cart controls.
4. Sign in as `maya@vibeshop.test` with `sunshine`. Inspect `My orders`, which intentionally does not filter ownership.
5. Open the public upload index linked in the README. These are fake text documents.
6. Use the forgot-password link and inspect the generated message in MailHog. Mail never leaves the lab.
7. Run `git log --oneline`. If the maintainer used `--init-git`, compare the fake Stripe key before and after its rotation commit. Both values are inert fixtures.
8. Use `make reset` to restore the original database state after experimenting.

Payments are simulated database writes, not real charges or refunds. The mock metadata credentials have no real AWS account behind them. Formal exploit/fix assertions need the original numbered module files.
