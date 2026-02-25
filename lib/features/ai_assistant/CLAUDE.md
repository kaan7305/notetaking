## AI Assistant Architecture

### Three modes
1. **Hint** — System prompt tells AI to only give conceptual nudges, reference the relevant concept and page, never reveal the answer
2. **Check** — Receives image of student's handwritten work (captured from canvas). AI evaluates correctness, identifies specific errors, explains what went wrong. References the relevant section in the course document.
3. **Solve** — Full solution with step-by-step reasoning. Every step references the source material (document name + page number).

### How it works
1. Student selects content (via lasso tool or taps the AI widget next to a question)
2. Selected strokes are rendered to a PNG image
3. Image + selected mode + conversation history → sent to backend
4. Backend runs RAG query against the student's uploaded documents (from PDR_AI_v2 pipeline)
5. Retrieved context chunks + image + mode-specific system prompt → OpenAI API
6. Response includes text + source references (doc name, page numbers)
7. Display response with clickable page reference buttons

### Source references
- Every AI response must include references in format: [filename.pdf, p.12]
- When user taps a reference, open the document viewer and scroll to that page
- Highlight the relevant sentences on the page (use the chunk boundaries from the RAG pipeline)
