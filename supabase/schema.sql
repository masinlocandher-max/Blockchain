-- Public Trust Infrastructure reference schema
-- Source-only baseline. Review and migrate deliberately before production use.

create extension if not exists pgcrypto;

create table if not exists organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  publication_public_key text,
  created_at timestamptz not null default now()
);

create table if not exists organization_members (
  organization_id uuid not null references organizations(id) on delete cascade,
  user_id uuid not null,
  role text not null check (role in ('owner','admin','approver','editor','auditor','viewer')),
  created_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  budget numeric(18,2) not null default 0 check (budget >= 0),
  currency char(3) not null default 'PHP',
  status text not null default 'active' check (status in ('draft','active','closed','archived')),
  created_by uuid not null,
  created_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table if not exists ledger_entries (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  entry_type text not null check (entry_type in ('funding','expense','adjustment','refund')),
  amount numeric(18,2) not null check (amount >= 0),
  occurred_on date not null,
  reference text not null,
  category text,
  description text,
  created_by uuid not null,
  created_at timestamptz not null default now()
);

create table if not exists evidence_objects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  ledger_entry_id uuid references ledger_entries(id) on delete set null,
  storage_key text not null,
  version integer not null default 1 check (version > 0),
  sha256 text not null check (sha256 ~ '^0x[0-9a-fA-F]{64}$'),
  media_type text,
  byte_size bigint check (byte_size >= 0),
  prior_version_id uuid references evidence_objects(id),
  uploaded_by uuid not null,
  created_at timestamptz not null default now(),
  unique (organization_id, storage_key, version)
);

create table if not exists snapshots (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  sequence_no bigint not null,
  canonicalization_version text not null default 'JCS-v1',
  snapshot_json jsonb not null,
  snapshot_hash text not null check (snapshot_hash ~ '^0x[0-9a-fA-F]{64}$'),
  previous_snapshot_hash text,
  state text not null default 'pending' check (state in ('pending','approved','published','revoked')),
  created_by uuid not null,
  created_at timestamptz not null default now(),
  finalized_at timestamptz,
  unique (organization_id, project_id, sequence_no),
  unique (organization_id, snapshot_hash)
);

create table if not exists snapshot_approvals (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  snapshot_id uuid not null references snapshots(id) on delete cascade,
  approver_user_id uuid not null,
  approved_snapshot_hash text not null,
  signature text,
  signature_algorithm text,
  created_at timestamptz not null default now(),
  unique (snapshot_id, approver_user_id)
);

create table if not exists transparency_log (
  organization_id uuid not null references organizations(id) on delete cascade,
  sequence_no bigint not null,
  snapshot_id uuid not null references snapshots(id) on delete restrict,
  snapshot_hash text not null,
  previous_entry_hash text,
  entry_hash text not null,
  published_at timestamptz not null default now(),
  primary key (organization_id, sequence_no),
  unique (organization_id, entry_hash)
);

create table if not exists anchor_batches (
  id uuid primary key default gen_random_uuid(),
  merkle_root text not null check (merkle_root ~ '^0x[0-9a-fA-F]{64}$'),
  leaf_count integer not null check (leaf_count > 0),
  network text,
  chain_id bigint,
  tx_hash text,
  block_number bigint,
  confirmations integer not null default 0,
  state text not null default 'queued' check (state in ('queued','submitted','confirmed','failed','reorged')),
  created_at timestamptz not null default now(),
  confirmed_at timestamptz
);

create table if not exists anchor_batch_leaves (
  batch_id uuid not null references anchor_batches(id) on delete cascade,
  snapshot_id uuid not null references snapshots(id) on delete restrict,
  leaf_index integer not null check (leaf_index >= 0),
  leaf_hash text not null,
  merkle_proof jsonb,
  primary key (batch_id, snapshot_id),
  unique (batch_id, leaf_index)
);

-- Prevent finalized snapshots from being silently mutated.
create or replace function prevent_finalized_snapshot_mutation()
returns trigger language plpgsql as $$
begin
  if old.state in ('approved','published') then
    if new.snapshot_json is distinct from old.snapshot_json
       or new.snapshot_hash is distinct from old.snapshot_hash
       or new.project_id is distinct from old.project_id
       or new.sequence_no is distinct from old.sequence_no then
      raise exception 'finalized snapshot content is immutable';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists snapshots_immutable_after_approval on snapshots;
create trigger snapshots_immutable_after_approval
before update on snapshots
for each row execute function prevent_finalized_snapshot_mutation();

-- Approval must bind to the exact current snapshot hash.
create or replace function enforce_approval_hash_binding()
returns trigger language plpgsql as $$
declare expected_hash text;
begin
  select snapshot_hash into expected_hash from snapshots where id = new.snapshot_id;
  if expected_hash is null or lower(expected_hash) <> lower(new.approved_snapshot_hash) then
    raise exception 'approval hash does not match snapshot';
  end if;
  return new;
end;
$$;

drop trigger if exists snapshot_approval_hash_binding on snapshot_approvals;
create trigger snapshot_approval_hash_binding
before insert or update on snapshot_approvals
for each row execute function enforce_approval_hash_binding();

-- RLS baseline. Production policies should bind auth.uid() to membership and role.
alter table organizations enable row level security;
alter table organization_members enable row level security;
alter table projects enable row level security;
alter table ledger_entries enable row level security;
alter table evidence_objects enable row level security;
alter table snapshots enable row level security;
alter table snapshot_approvals enable row level security;
alter table transparency_log enable row level security;
