# Kirana AI - Backend Service

FastAPI-powered backend service for Kirana AI assistant.

## Features (Planned)
- **FastAPI Core**: Async REST endpoints for transactions, inventory, customers, and business summaries.
- **Natural Language Parsing**: Extract structured transaction intent (item, quantity, amount, payment mode, udhaar/credit) from English and Hinglish shopkeeper inputs.
- **Voice / Audio Processing**: Speech-to-text pipeline for audio notes.
- **WhatsApp Integration (Twilio / Meta Cloud API)**: Allow shopkeepers to log entries directly via WhatsApp messages and voice notes.
- **GST & Ledger Summaries**: Daily/monthly sales, GST calculation, and PDF/WhatsApp report generator.

## Getting Started (When ready)
```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Install requirements:
pip install -r requirements.txt
# Run dev server:
uvicorn app.main:app --reload --port 8000
```
