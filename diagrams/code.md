flowchart System Context:
  UI[Web UI / Power App] --> Engine[Transcript Engine]
  UI --> Ops[Audit & Ops Logs]
  Engine --> Adapter[Records Integration Adapter]
  Engine --> Doc[Document Service (PDF + Storage)]
  UI --> Msg[Messaging Service (Email)]
  Adapter --> Records[(External Records Source)]
  Doc --> Storage[(Secure Document Storage)]
  Msg --> Mail[(Email Provider)]


Data Model ER Diagram:
  Students ||--o{ TranscriptRequests : has
  TranscriptTypes ||--o{ TranscriptRequests : uses
  TranscriptRequests ||--o| TranscriptDocuments : produces
  TranscriptRequests ||--o{ EmailLogs : emails
  EmailTemplates ||--o{ EmailLogs : based_on
  BatchRuns ||--o{ BatchRunItems : contains
  Students ||--o{ BatchRunItems : targets
  TranscriptRequests ||--o{ BatchRunItems : links_optional
