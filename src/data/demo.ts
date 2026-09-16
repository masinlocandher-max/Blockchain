export type Project = {
  id: string;
  name: string;
  organization: string;
  budget: number;
  spent: number;
  status: 'Active' | 'Finalized';
  snapshotHash: string;
  anchored: boolean;
};

export const projects: Project[] = [
  {
    id: 'PTR-2026-001',
    name: 'Community Learning Center',
    organization: 'Demo Public Trust Organization',
    budget: 2500000,
    spent: 1874200,
    status: 'Finalized',
    snapshotHash: '0x6e53c4d8e647d0d8e16a9ad629847327848831e72cd92fe79ecf95f5cc5f7813',
    anchored: true,
  },
  {
    id: 'PTR-2026-002',
    name: 'Disaster Preparedness Equipment',
    organization: 'Demo Public Trust Organization',
    budget: 900000,
    spent: 436500,
    status: 'Active',
    snapshotHash: 'Pending finalization',
    anchored: false,
  },
];

export const ledger = [
  { date: '2026-08-03', ref: 'EXP-1043', category: 'Construction', amount: 640000, evidence: 8, state: 'Verified' },
  { date: '2026-08-11', ref: 'EXP-1078', category: 'Learning Equipment', amount: 484200, evidence: 5, state: 'Verified' },
  { date: '2026-08-24', ref: 'EXP-1121', category: 'Electrical Works', amount: 320000, evidence: 4, state: 'Verified' },
  { date: '2026-09-02', ref: 'EXP-1146', category: 'Furniture', amount: 430000, evidence: 6, state: 'Verified' },
];
