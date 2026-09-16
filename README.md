# Blockchain — Public Trust Infrastructure

A transparency and verification platform for LGUs, NGOs, foundations, associations, and other organizations that need to prove that financial and program records have not been silently altered.

## Product principle

This is **not a cryptocurrency product**. There is no token, NFT, speculative asset, or public-chain dependency in normal day-to-day operations.

PostgreSQL remains the operational system of record. Evidence files are stored separately. Finalized record snapshots are canonicalized, hashed, approved, appended to a tamper-evident log, batched into Merkle trees, and only the resulting proof/root is anchored on-chain.

## Core flow

1. An organization creates a project or program.
2. Budgets, funding, expenses, receipts, evidence, and approvals are recorded.
3. A finalized reporting set is converted into a deterministic immutable snapshot.
4. Approvers approve the exact snapshot hash, not a mutable database row.
5. Evidence is versioned and locked rather than overwritten.
6. The snapshot enters an append-only transparency log.
7. Finalized records can be batched into a Merkle tree.
8. Only the Merkle root or snapshot proof is anchored on-chain.
9. Public transparency pages expose only approved data.
10. Citizens, donors, auditors, and regulators can independently verify published records.

## Security baseline

- Immutable snapshot-bound approvals
- Deterministic canonicalization
- Append-only sequential transparency log
- Evidence versioning and object-lock/WORM-ready storage
- Organization publication signatures separated from blockchain anchoring
- Tenant isolation and PostgreSQL RLS defense-in-depth
- MFA/passkey-ready admin authentication
- Independent public verification
- Multisig/HSM-ready anchoring key control
- Chain confirmation, reorg, retry, and reconciliation handling
- No raw sensitive documents or personal data written to a public blockchain

## Repository structure

```text
src/                    Frontend prototype
  lib/proof.ts           Canonicalization + SHA-256 verification utilities
  data/demo.ts           Demonstration records
supabase/schema.sql      Multi-tenant data model, RLS and immutable snapshot model
contracts/               Minimal anchoring contract reference
architecture/            System and security documentation
```

## Local development

```bash
npm install
npm run dev
```

The current frontend is a production-oriented demonstrator. Blockchain writes are intentionally simulated until an audited chain, signer policy, RPC provider, and key-management configuration are selected.

## Deployment model

```text
Web / Mobile UI
      ↓
Application API / Edge Functions
      ↓
Supabase Auth + PostgreSQL + RLS
      ↓
Immutable Snapshots + Evidence Manifest
      ↓
Append-only Transparency Log
      ↓
Merkle Batch Builder
      ↓
Anchoring Service + Multisig/HSM
      ↓
Blockchain

Public Verifier independently recomputes proofs from published snapshots.
```

## Status

Initial repository baseline. The next production milestone is to connect the UI to Supabase, implement signed publication workflows, add Merkle batch jobs, deploy an audited anchoring contract, and add an independent verifier service.

## License

Private/commercial use policy to be defined by the repository owner.
