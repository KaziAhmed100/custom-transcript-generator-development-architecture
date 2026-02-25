# Framework Blueprint: Custom Transcript Generator

**Document Type:** Implementation Blueprint  
**Scope:** Functional modules, workflow contracts, integration boundaries  
**Status:** Public Reference (Generic)

---

## 1. Goals

### 1.1 Primary goals
- Generate transcripts in **multiple formats** (standard + specialized)
- Enable **preview before PDF**
- Support **secure PDF storage** and **email delivery**
- Support **batch generation** with success/failure isolation
- Maintain **auditability** (who generated/sent, when, what happened)

### 1.2 Non-goals
- Not a full student information system (SIS)
- Not a grade entry tool
- Not a definitive source of academic truth (it *consumes* records)

---

## 2. High-Level Architecture

### 2.1 Modules
1. **UI Module**
   - Student search
   - Transcript preview
   - PDF actions (create, download, email)
   - Batch processing UI
   - Template management UI

2. **Transcript Engine**
   - Converts “academic record” → “transcript model”
   - Applies format rules, totals, sorting, layout constraints
   - Output: structured JSON model usable by preview and PDF renderer

3. **Records Integration Adapter**
   - Reads academic record data from an external source
   - Can be implemented with API, DB view, file import, etc.
   - Must be abstracted so the rest of the app is not tied to the source

4. **Document Service**
   - PDF rendering (HTML-to-PDF, template-based, or report engine)
   - Storage abstraction (document library, blob storage, file server)

5. **Messaging Service**
   - Email delivery
   - Template merge and variable injection
   - Logging + retry handling

6. **Audit & Operations**
   - Request logs
   - Document logs
   - Email logs
   - Batch job logs
   - Minimal error details for troubleshooting without exposing PII

---

## 3. Core Workflows

### 3.1 Single transcript generation (Preview → PDF)
**Step sequence**
1. Staff searches student (by external identifier)
2. System validates access + eligibility
3. Integration adapter fetches academic record
4. Transcript engine generates a **TranscriptModel**
5. UI renders preview from TranscriptModel
6. User selects: **Create PDF**
7. Document service generates PDF and stores it securely
8. System logs outcome (success/failure)

**Output artifacts**
- TranscriptRequest
- TranscriptDocument (if generated)
- Audit events

---

### 3.2 Email transcript (PDF → Email → Log)
**Step sequence**
1. User chooses email template or composes custom message
2. System validates recipient + permissions
3. System fetches existing PDF OR generates on-demand
4. Messaging service sends email
5. Email log recorded (sent/failed)
6. Request status updated

---

### 3.3 Batch transcript generation (Course/Section/Cohort)
**Step sequence**
1. User selects scope (course/section/cohort/date range)
2. System resolves list of target students
3. BatchRun created
4. For each student:
   - fetch record
   - generate model
   - create PDF
   - optionally email
   - write BatchRunItem outcome
5. BatchRun summary updated (counts + timestamps)

**Rules**
- Continue-on-error: a failure for one student must not stop the entire batch
- Record failure reason using safe error codes/messages

---

## 4. Key Contracts (Interfaces)

### 4.1 Academic Record Contract (input)
**`AcademicRecord` minimal fields**
- StudentRef (external identifier)
- StudentName (optional; privacy-safe)
- Program/Track (optional)
- Completions[]:
  - Term/Session
  - CourseCode, CourseTitle
  - Credits/Hours
  - Grade/Result
  - CompletionDate

### 4.2 Transcript Model Contract (internal output)
**`TranscriptModel` includes**
- Header: student display fields (minimal)
- Sections[] (e.g., by term/session):
  - Rows: course line items
  - Subtotals
- Totals (credits/hours)
- Footnotes/disclaimers
- TemplateVariables (for email merge)

### 4.3 PDF Rendering Contract
Input: TranscriptModel + TranscriptType  
Output: PDF bytes + storage metadata

---

## 5. Security & Privacy Design (framework-level)

- Enforce role-based permissions (view, generate, email, batch)
- Avoid storing raw academic record data unless required
- Store documents in restricted storage with access controls
- Logs should avoid full PII content; store references and safe summaries

---

## 6. Extensibility (Transcript Types)

Transcript types can differ by:
- Layout (header and sections)
- Sorting rules
- Inclusion/exclusion of fields
- Specialized footnotes
- Different templates

Design recommendation:
- TranscriptType table + per-type rendering rule configuration
- “Rules engine” pattern inside Transcript Engine

---

## 7. Operational Considerations

- Rate limits & throttling for email
- Retry policy for PDF generation and storage
- Monitoring: daily job summaries, failure alerts
- Testing: snapshot tests for TranscriptModel rendering and PDF layouts
