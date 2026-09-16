# Public Trust Infrastructure — Product Blueprint

## Positioning

A verification layer for organizations that need the public, donors, auditors, regulators, or partner institutions to trust published records without relying only on institutional reputation.

Primary users:

- Local government units
- NGOs and foundations
- Associations and cooperatives
- Development programs
- Grant-funded projects
- Public-private initiatives

The system should feel like a modern transparency and audit product. Blockchain should remain largely invisible to ordinary users.

## Core modules

### Organization workspace

Multi-tenant workspace for teams, roles, projects, approval policies, and publication settings.

### Projects and programs

Projects hold budgets, funding events, expenditures, categories, milestones, evidence, reporting periods, and publication status.

### Ledger

Operational financial/activity records remain in PostgreSQL. Records can be corrected while still in a mutable workflow state. Once included in a finalized snapshot, history is preserved through versioning rather than destructive editing.

### Evidence vault

Receipts, documents, images, certificates, reports, procurement records, and other evidence are stored outside the blockchain. Every evidence version receives a SHA-256 content digest and immutable identity.

### Snapshot engine

A reporting period or selected record set is transformed into a deterministic canonical document. The canonical byte representation is hashed. The snapshot includes enough context to prevent replay across projects, organizations, or sequence positions.

Recommended identity fields include:

- schema version
- canonicalization version
- organization ID
- project ID
- reporting period
- sequence number
- previous snapshot hash
- ledger records and evidence manifest
- created/finalized timestamp policy

### Approval workflow

Approvers sign or explicitly attest to the exact snapshot hash. Approval records are invalid if they do not match the snapshot hash.

Organizations may configure thresholds, for example two-of-three approvers before publication.

### Transparency log

Published snapshots enter an append-only organization-scoped sequence. Each entry commits to the previous entry to make rewriting or removal detectable.

### Merkle batcher

Finalized snapshot hashes are grouped into batches. A deterministic Merkle tree is built and the root is sent to the blockchain anchoring service. Each published snapshot retains its Merkle inclusion proof.

### Blockchain anchor

The blockchain stores the minimum useful commitment:

- Merkle root
- leaf count
- metadata/configuration commitment if required
- block timestamp and transaction metadata are obtained from the chain

No personal or sensitive operational data belongs on-chain.

### Public transparency portal

Public project pages may show:

- program description
- approved budget
- funding received
- expenditure totals
- categorized transactions
- redacted/public evidence
- approval state
- publication history
- correction/supersession chain
- verification state
- QR verification link

### Independent verifier

Verification should not require trusting the primary application server. A verifier can:

1. obtain the published snapshot,
2. canonicalize it using the declared version,
3. recompute its SHA-256 hash,
4. validate the organization's publication signature,
5. verify the transparency-log relationship,
6. verify its Merkle inclusion proof,
7. verify that the Merkle root exists in the blockchain anchor transaction.

## Suggested production architecture

```text
Admin / Auditor / Public UI
        |
        v
Application API / Edge Functions
        |
        +--> Supabase Auth
        |
        +--> PostgreSQL + RLS
        |
        +--> Evidence object storage
        |
        +--> Snapshot / canonicalization service
                     |
                     v
              Approval workflow
                     |
                     v
          Append-only transparency log
                     |
                     v
              Merkle batch worker
                     |
                     v
           Isolated anchoring service
                     |
                     v
             Multisig / HSM / MPC
                     |
                     v
                 Blockchain

Independent verifier reads published snapshot + proof + chain data.
```

## Product phases

### Phase 1 — Source prototype

Dashboard, project views, ledger, evidence concepts, proof state, deterministic hashing utilities, schema, threat model. No deployment.

### Phase 2 — Application integrity

Supabase Auth, tenant RLS, projects, ledger, evidence uploads, canonical snapshot engine, approval binding, append-only logs, audit events, public read model.

### Phase 3 — Cryptographic publication

Organization signing keys, publication signatures, Merkle batching, inclusion proofs, independent verifier.

### Phase 4 — Blockchain anchoring

Select chain based on permanence, transaction cost, ecosystem durability, tooling, finality, and operational risk. Audit anchoring contract and signer controls before deployment.

### Phase 5 — Institutional controls

Configurable approval thresholds, retention policies, procurement/grant workflows, external auditor roles, export packages, incident/recovery procedures, compliance review.

## Non-goals

- cryptocurrency
- tokens
- NFTs
- speculative finance
- putting documents or PII on a public chain
- replacing accounting systems
- claiming that blockchain makes inaccurate source data truthful

The product proves integrity and publication history. It does not prove that a false statement was true when first entered. That requires governance, evidence, approvals, audits, and institutional controls.
