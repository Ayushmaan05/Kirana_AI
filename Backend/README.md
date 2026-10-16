# Kirana AI - Backend Service

FastAPI-powered backend service for Kirana AI assistant.

## Features (Planned)
- **FastAPI Core**: Async REST endpoints for transactions, inventory, customers, and business summaries.
- **Natural Language Parsing**: Extract structured transaction intent (item, quantity, amount, payment mode, udhaar/credit) from English and Hinglish shopkeeper inputs.
- **Voice / Audio Processing**: Speech-to-text pipeline for audio notes.
- **WhatsApp Integration (Twilio / Meta Cloud API)**: Allow shopkeepers to log entries directly via WhatsApp messages and voice notes.
- **GST & Ledger Summaries**: Daily/monthly sales, GST calculation, and PDF/WhatsApp report generator.

## Current status

The backend is not implemented yet: this directory has no application module
or dependency manifest, so there is no API server to install or run at present.
The frontend can be run independently in demo mode; see the repository
[Getting Started](../README.md#getting-started) instructions.

When the backend is implemented, keep server-side credentials in
`Backend/.env` (see `.env.example`). Never expose them through frontend
environment variables.
