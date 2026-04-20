---
name: atmos-demo-bump
description: Use when demoing Atmos Pro / Terraform plan changes on this repo's mock components — either (a) bumping a `<component>_version` in a stack to produce a visible plan diff, or (b) wiring up a new or existing mock component with the version-bump demo pattern (random_id keepers + null_resource triggers). Triggered by requests like "bump the cluster version", "set up the <x> component so I can demo a change", "why does the plan show no infrastructure changes", or "add triggers to component X".
---

# Atmos Demo Bump

This repo is an Atmos Pro example. The Terraform components under `components/terraform/` (except `dynamodb`, which is a real AWS module) are **mocks** — they only manage `random_id` resources. To make a plan *show a real infrastructure change* during a demo, each component exposes a `<component>_version` input variable, and that variable is wired to `random_id.keepers` and a `null_resource.triggers`. Bumping the version in a stack forces recreates, which surfaces as real plan lines (not just output-only diffs).

## Two things this skill covers

1. **Bumping an existing demo** — produce a visible plan change in a specific stack.
2. **Wiring a component** — add the demo pattern to a new or existing mock component.

---

## 1. Bumping an existing demo

**Goal:** user asks something like "bump the cluster version in dev" or "demo a change on frontend in staging." You need to produce a Terraform plan that shows real replacements, not just `output values will change`.

### Steps

1. Identify the stack file. Stack files live under `stacks/orgs/<org>/<tenant>/<stage>/<region>/<stack>.yaml`. Example for dev: `stacks/orgs/ex1/plat/dev/us-east-2/demo.yaml`.
2. Find the component block (e.g. `cluster:` under `components.terraform:`).
3. Find or add the `<component>_version` var under `vars:` and bump it. **Always quote the value** — Atmos/YAML will otherwise drop trailing zeros. Use semver-looking strings (e.g. `"1.1.0"` → `"2.0.0"`).
4. If the var doesn't exist in the stack yet, it means the stack is inheriting the catalog default (`stacks/catalog/<component>.yaml`) — add it to the env stack, not the catalog, so only that env is bumped.
5. Commit with a short imperative message, e.g. `Bump dev cluster version to 2.0.0`.

### Verify

- `atmos describe component <component> -s <stack>` — resolved `vars.<component>_version` matches the new value.
- `atmos terraform plan <component> -s <stack>` — plan shows `# ... will be replaced` lines for `random_id.id` and/or `null_resource.<component>_version`. If the plan *only* shows `Output values will change. No infrastructure changes.`, the triggers aren't wired — go to section 2 and fix the component first.

### Pitfalls

- Terraform reserves bare names like `version`, `count`, `for_each`. Never name the input variable just `version` — always use the `<component>_version` form (`cluster_version`, `api_version`, etc.). This repo already follows that rule.
- If you want several envs bumped, set them in each env's stack file. Don't touch the catalog default unless you want every stack that inherits it to move together.

---

## 2. Wiring a component with the demo pattern

**Goal:** a mock component currently has no `<component>_version` variable, or the variable exists but isn't tied to any resource, so bumps don't show plan changes.

### The pattern (reference: `components/terraform/cluster/main.tf`)

Every mock component should have four pieces:

```hcl
# 1. The input variable — always prefix with the component name
variable "cluster_version" {
  description = "Version of the cluster"
  type        = string
  default     = "1.0.0"
}

# 2. random_id with the version in keepers — rotates the random suffix on bump
resource "random_id" "id" {
  byte_length = 8
  keepers = {
    name            = var.name
    cluster_version = var.cluster_version
  }
}

# 3. null_resource with the version in triggers — gives an unambiguous "replace" line in the plan
resource "null_resource" "cluster_version" {
  triggers = {
    cluster_version = var.cluster_version
  }
}

# 4. Output the version so downstream components / dashboards can see it
output "cluster_version" {
  value = var.cluster_version
}
```

### Steps to wire a component

1. Open `components/terraform/<component>/main.tf`.
2. Add the `variable "<component>_version"` block (default `"1.0.0"`).
3. Add `<component>_version = var.<component>_version` to the existing `random_id.id` resource's `keepers` map.
4. Add a `null_resource.<component>_version` with `triggers.<component>_version = var.<component>_version`.
5. Add an `output "<component>_version"`.
6. Check `components/terraform/<component>/providers.tf` exists and declares `provider "random"`. If the file is missing, create it:
   ```hcl
   provider "random" {}
   ```
   The `null` provider does not need to be configured — Terraform ships `null_resource` implicitly.
7. Update the catalog default at `stacks/catalog/<component>.yaml` to set `vars.<component>_version: "1.0.0"` so the baseline is explicit.

### Naming rule

Always use `<component>_version`. Do NOT use bare `version` — Terraform reserves it. This rule is consistent across the repo.

### Skip list

- `components/terraform/dynamodb/` — this is a real `cloudposse/dynamodb/aws` module, not a mock. Don't add mock triggers there. Demo changes here by toggling real module inputs (e.g. `billing_mode`).

---

## Quick sanity check before finishing

Before handing back to the user:

- Did the plan show real replacements (not just output-only diffs)?
- If you added the pattern to a component, did you update the catalog to include `<component>_version` as an explicit default?
- Did you quote the version value in YAML?
