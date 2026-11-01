Below is a **comprehensive taxonomy of software audits** you can perform. This is structured so you can directly convert it into a **system prompt** later by enabling/disable audit categories.

---

## 1. Performance Audit

Focus: **Speed, efficiency, scalability**

Covers:

- Time complexity (hot paths, N+1 issues)
- Memory usage & leaks
- CPU / GPU utilization
- I/O bottlenecks (DB, network, disk)
- Caching effectiveness
- Cold start & startup time
- Concurrency & parallelism
- Load, stress, soak behavior

Typical outputs:

- Bottleneck identification
- Profiling insights
- Optimization recommendations
- Scaling limits & thresholds

---

## 2. Code Quality Audit

Focus: **Maintainability & correctness**

Covers:

- Code duplication & DRY violations
- Function/class size & responsibilities
- Readability & naming
- Dead code & unused abstractions
- Error handling consistency
- Type safety & contracts
- Linting & formatting compliance
- Testability of components

Typical outputs:

- Refactoring suggestions
- Utility extraction candidates
- Anti-pattern detection

---

## 3. Architecture Audit

Focus: **System-level design correctness**

Covers:

- Layering & separation of concerns
- Module boundaries
- Dependency direction & coupling
- Monolith vs modular vs microservices suitability
- Event-driven vs request-driven tradeoffs
- Data flow correctness
- Scalability & fault tolerance design

Typical outputs:

- Architecture flaws
- Suggested restructuring
- Design pattern recommendations

---

## 4. API Audit

Focus: **Public & internal interfaces**

Covers:

- REST/GraphQL/gRPC correctness
- HTTP semantics (status codes, verbs)
- Versioning strategy
- Pagination, filtering, sorting
- Error response consistency
- Schema validation
- Backward compatibility
- Idempotency & retries

Typical outputs:

- API contract improvements
- Breaking-change risks
- Spec alignment (OpenAPI/AsyncAPI)

---

## 5. Security Audit

Focus: **Attack surface & data protection**

Covers:

- Authentication & authorization
- Input validation & sanitization
- Injection risks (SQL, NoSQL, XSS, command)
- Secrets handling
- Encryption (at rest & in transit)
- Dependency vulnerabilities
- RBAC / ABAC correctness
- Rate limiting & abuse protection

Typical outputs:

- Vulnerability list (severity-tagged)
- Exploit scenarios
- Remediation steps

---

## 6. Dependency & Supply Chain Audit

Focus: **Third-party risk**

Covers:

- Outdated dependencies
- Known CVEs
- License compatibility
- Transitive dependency risks
- Dependency bloat
- Build reproducibility

Typical outputs:

- Upgrade plan
- Removal recommendations
- License risk assessment

---

## 7. Database & Data Model Audit

Focus: **Data correctness & efficiency**

Covers:

- Schema design
- Index usage
- Query performance
- Data normalization vs denormalization
- Migrations safety
- Transaction boundaries
- Consistency guarantees
- Backup & recovery readiness

Typical outputs:

- Query optimizations
- Schema refactor suggestions
- Migration risks

---

## 8. Reliability & Resilience Audit

Focus: **Failure handling**

Covers:

- Graceful degradation
- Retry & circuit breaker usage
- Timeout strategies
- Idempotency
- Crash recovery
- Data loss scenarios
- Disaster recovery readiness

Typical outputs:

- Failure mode analysis
- Resilience improvements
- Chaos-test gaps

---

## 9. Observability Audit

Focus: **Visibility into the system**

Covers:

- Logging quality & structure
- Metrics coverage
- Tracing completeness
- Alerting relevance
- Signal-to-noise ratio
- Debuggability in production

Typical outputs:

- Missing signals
- Logging/metrics strategy
- Alert fatigue risks

---

## 10. DevEx (Developer Experience) Audit

Focus: **Ease of development**

Covers:

- Onboarding friction
- Local setup complexity
- Build & test speed
- Tooling consistency
- Documentation accuracy
- DX ergonomics (scripts, CLIs)

Typical outputs:

- DX pain points
- Automation recommendations
- Docs improvements

---

## 11. UI/UX Audit (if applicable)

Focus: **End-user experience**

Covers:

- Usability issues
- Accessibility (WCAG)
- Responsiveness & performance
- Interaction consistency
- Error states & feedback
- Visual hierarchy

Typical outputs:

- UX flaws
- Accessibility gaps
- Design improvements

---

## 12. Compliance & Governance Audit

Focus: **Rules, laws, and standards**

Covers:

- Data privacy (GDPR, etc.)
- Audit logs
- Retention policies
- Access traceability
- Industry standards (ISO, SOC)

Typical outputs:

- Compliance gaps
- Risk exposure
- Policy enforcement suggestions

---

## 13. Testing & Quality Assurance Audit

Focus: **Confidence & correctness**

Covers:

- Test coverage (unit, integration, e2e)
- Flaky tests
- Test data quality
- Assertion strength
- CI reliability
- Regression risks

Typical outputs:

- Coverage gaps
- Testing strategy fixes
- CI instability causes

---

## 14. Deployment & Infrastructure Audit

Focus: **Runtime & delivery pipeline**

Covers:

- CI/CD pipeline efficiency
- Environment parity
- Infrastructure as Code quality
- Rollback strategies
- Blue/green & canary setups
- Cost efficiency

Typical outputs:

- Pipeline bottlenecks
- Infra risks
- Cost-saving opportunities

---

## 15. Product & Business Logic Audit

Focus: **Correctness of intent**

Covers:

- Business rule implementation accuracy
- Edge-case handling
- Assumption mismatches
- Feature flag correctness
- Analytics correctness

Typical outputs:

- Logic bugs
- Requirement mismatches
- Silent failure risks

---

## 16. Documentation Audit

Focus: **Knowledge durability**

Covers:

- Code comments usefulness
- Architecture docs accuracy
- API docs completeness
- Runbooks
- ADRs (Architecture Decision Records)

Typical outputs:

- Missing docs
- Stale documentation
- Critical knowledge gaps

---

## How This Helps Your System Prompt

You can structure your **system prompt** like:

- Enable/disable audit categories
- Specify depth (high-level vs deep dive)
- Require severity tagging
- Require actionable refactors
- Require evidence-based reasoning
- Require no-code vs code suggestions
