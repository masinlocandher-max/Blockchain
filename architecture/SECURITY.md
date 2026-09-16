# Security Architecture

## Objective

The system must make finalized public records difficult to alter without detection while keeping sensitive operational data off-chain.

Blockchain is an external timestamp/integrity anchor, not the primary database.

## Trust boundaries

1. **Client applications** are untrusted input environments.
2. **Application API / Edge Functions** enforce authorization and workflow rules.
3. **PostgreSQL** stores operational records under tenant isolation and RLS.
4. **Evidence storage** stores documents and media separately from the ledger.
5. **Snapshot service** canonicalizes finalized data and computes hashes.
6. **Transparency log** is append-only and hash-linked.
7. **Batch builder** creates Merkle trees from finalized snapshot hashes.
8. **Anchoring service** submits only Merkle roots and minimal metadata commitments.
9. **Public verifier** must be able to recompute a snapshot hash and Merkle inclusion proof independently.

## Core invariants

### Snapshot immutability

Once a snapshot enters an approved or published state, its canonical content, sequence number, project binding, and hash must not change. Corrections create a new snapshot/version rather than editing history.

### Approval binding

Approvals are bound to a specific snapshot hash. An approval must not remain valid if the underlying content changes.

### Evidence integrity

Each evidence object has a SHA-256 digest and explicit version. Replacements create a new version and retain linkage to the prior version.

### Tenant isolation

Every protected object carries an `organization_id`. Authorization must be enforced in both the API layer and PostgreSQL RLS policies.

### Minimal on-chain data

Never write names, personal data, receipts, descriptions, account numbers, addresses, or raw files to a public blockchain. Only non-sensitive commitments such as Merkle roots and metadata hashes belong on-chain.

## Key threats and controls

| Threat | Required control |
| --- | --- |
| Admin edits a finalized report | Immutable finalized snapshots + new-version correction workflow |
| Approver signs one record and publisher swaps another | Approval bound to canonical snapshot hash |
| Database administrator rewrites history | Hash-linked transparency log + external chain anchor |
| Evidence file replaced | Content hash + versioning + object-lock/WORM capable storage |
| Cross-organization data leak | RLS + organization-scoped queries + API authorization |
| Stolen anchoring key | Multisig or HSM/MPC signer policy + limited anchoring permissions |
| Malicious client fabricates a hash | Server-side canonicalization and hash calculation |
| Chain reorganization | Confirmation thresholds + reconciliation state + re-anchor policy |
| RPC/provider outage | Queue submissions; operational system continues without losing finalized snapshots |
| Blockchain becomes unavailable | Verification remains possible from publication signatures and transparency log; anchors can resume later |
| Insider deletes unpublished records | Audit log + least privilege + backup/retention policy |
| Replay of an old proof | Sequence number, project ID, publication timestamp and current/publication state included in canonical snapshot |

## Authentication

Production administrative roles should use MFA. Owners and high-privilege approvers should use passkeys/WebAuthn where available. Recovery flows need stronger controls than ordinary login because account recovery is a common bypass path.

## Signing separation

There are two separate trust actions:

1. **Organization publication signature**: proves the organization published a specific snapshot.
2. **Blockchain anchor**: proves a commitment existed no later than the confirmed chain transaction.

These should use separate keys and preferably separate signing systems.

## Anchor key policy

The anchoring account should not hold funds beyond what is needed for bounded transaction fees. Prefer a multisig or managed HSM/MPC configuration. A single developer wallet must not become the production root of trust.

## Canonicalization

Hashing arbitrary JSON strings is unsafe because equivalent objects may serialize differently. Production implementation should use an explicitly versioned canonical JSON specification, such as RFC 8785/JCS, and should include the canonicalization version in each snapshot.

## Publication and correction model

Published records are never silently overwritten. A correction references the prior snapshot and provides a new snapshot, new approvals, and a new proof. Public UI should show the supersession chain.

## What the current repository is

This repository is a source-code baseline and architecture demonstrator. It is not deployed, not connected to a production database, and the reference smart contract has not been audited or deployed.
