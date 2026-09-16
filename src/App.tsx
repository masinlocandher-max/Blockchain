import { useMemo, useState } from 'react';
import { ledger, projects } from './data/demo';

const money = new Intl.NumberFormat('en-PH', {
  style: 'currency',
  currency: 'PHP',
  maximumFractionDigits: 0,
});

export default function App() {
  const [selected, setSelected] = useState(projects[0]);
  const utilization = useMemo(
    () => Math.round((selected.spent / selected.budget) * 100),
    [selected],
  );

  return (
    <main className="shell">
      <aside className="sidebar">
        <div>
          <p className="eyebrow">PUBLIC TRUST INFRASTRUCTURE</p>
          <h1>Blockchain</h1>
          <p className="muted">Verification without crypto noise.</p>
        </div>
        <nav>
          <button className="nav active">Overview</button>
          <button className="nav">Projects</button>
          <button className="nav">Ledger</button>
          <button className="nav">Evidence</button>
          <button className="nav">Snapshots</button>
          <button className="nav">Verifier</button>
        </nav>
        <div className="sidebarFoot">
          <span className="dot" /> Source-only prototype
        </div>
      </aside>

      <section className="content">
        <header className="topbar">
          <div>
            <p className="eyebrow">ORGANIZATION WORKSPACE</p>
            <h2>Transparency Console</h2>
          </div>
          <div className="secure">Integrity controls active</div>
        </header>

        <section className="hero">
          <div>
            <p className="eyebrow">TRUST, PROVABLE</p>
            <h3>Records people do not have to simply take your word for.</h3>
            <p className="lede">
              Operational records stay in the database. Finalized snapshots become tamper-evident,
              independently verifiable proofs.
            </p>
          </div>
          <div className="proofCard">
            <span>Latest proof state</span>
            <strong>ANCHORED</strong>
            <code>{projects[0].snapshotHash.slice(0, 20)}…</code>
          </div>
        </section>

        <section className="stats">
          <article><span>Projects</span><strong>{projects.length}</strong></article>
          <article><span>Approved spend</span><strong>{money.format(projects.reduce((a,p)=>a+p.spent,0))}</strong></article>
          <article><span>Evidence files</span><strong>23</strong></article>
          <article><span>Integrity exceptions</span><strong>0</strong></article>
        </section>

        <section className="grid">
          <article className="panel projects">
            <div className="panelHead"><div><p className="eyebrow">PROGRAMS</p><h3>Projects</h3></div><span>{projects.length} records</span></div>
            <div className="projectList">
              {projects.map((project) => (
                <button key={project.id} onClick={() => setSelected(project)} className={selected.id === project.id ? 'project selected' : 'project'}>
                  <div><strong>{project.name}</strong><span>{project.id}</span></div>
                  <span className={project.anchored ? 'pill good' : 'pill'}>{project.anchored ? 'Anchored' : 'Open'}</span>
                </button>
              ))}
            </div>
          </article>

          <article className="panel detail">
            <div className="panelHead"><div><p className="eyebrow">SELECTED RECORD</p><h3>{selected.name}</h3></div><span>{selected.status}</span></div>
            <div className="budget"><div><span>Budget</span><strong>{money.format(selected.budget)}</strong></div><div><span>Recorded spend</span><strong>{money.format(selected.spent)}</strong></div></div>
            <div className="meter"><i style={{ width: `${utilization}%` }} /></div>
            <p className="small">{utilization}% budget utilization</p>
            <div className="hash"><span>Snapshot proof</span><code>{selected.snapshotHash}</code></div>
          </article>
        </section>

        <section className="panel tablePanel">
          <div className="panelHead"><div><p className="eyebrow">APPEND-ONLY VIEW</p><h3>Recent ledger records</h3></div><span>Evidence linked</span></div>
          <div className="tableWrap"><table><thead><tr><th>Date</th><th>Reference</th><th>Category</th><th>Amount</th><th>Evidence</th><th>State</th></tr></thead><tbody>
            {ledger.map((row) => <tr key={row.ref}><td>{row.date}</td><td>{row.ref}</td><td>{row.category}</td><td>{money.format(row.amount)}</td><td>{row.evidence} files</td><td><span className="pill good">{row.state}</span></td></tr>)}
          </tbody></table></div>
        </section>

        <footer>Prototype only. No blockchain transaction is sent from this interface.</footer>
      </section>
    </main>
  );
}
