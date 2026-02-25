# System Framework

## Components

1. **Power Apps (Web UI)**
   - Home screen with navigation cards:
     - Student Transcripts
     - Batch Transcripts
     - Special Transcript Types
     - Email Templates
   - Student list/search screen
   - Transcript preview screen with actions: Create PDF / Email PDF
   - Email composition screen
   - Batch generation screen (course + section selection)
   - Template management screen

2. **Data Layer**
   - **Operational data** stored in SharePoint lists:
     - Email templates
     - Generation history/logs
     - Batch runs
     - Configuration tables
   - **Student/course completion data** fetched from an existing grading/records system (integration)

3. **Automation Layer (Power Automate)**
   - Generate PDF transcript from transcript data + template
   - Store PDF in secure document library/folder
   - Email PDF transcript to student
   - Batch processing loop and outcome tracking

4. **Distribution/Access**
   - Web access from any authorized device
   - Optional embedding into collaboration tooling (e.g., Teams) for simple staff access without device installation 

## Data Flow (Conceptual)

### Single Student Transcript
1. Staff searches student by identifier in Power Apps
2. App calls integration to retrieve completion data
3. App renders transcript preview (screen)
4. Staff chooses:
   - **Create PDF** → Flow generates PDF + stores in secured location
   - **Email PDF** → Flow generates PDF + emails + logs send event

### Batch Transcript Run
1. Staff selects course + section
2. App queries eligible students
3. Staff previews one transcript for validation
4. Staff starts batch job
5. Flow loops through students:
   - generate PDF
   - store (optional)
   - email (optional)
   - log success/failure
6. App displays batch results summary

## Operational Considerations

- **Auditability:** log each PDF generation and email event
- **Resilience:** retries + per-student failure isolation in batch runs
- **Performance:** delegation-aware filtering/search in Power Apps for large lists
- **Security:** restricted access to transcript storage + controlled email sending
