from datetime import datetime, timezone

TICKETS: dict = {}
_counter = [0]


def _next_id() -> str:
    _counter[0] += 1
    return f"TK-{_counter[0]:03d}"


def _ok(body: str) -> dict:
    return {"response": {"functionResponse": {"responseBody": {"TEXT": {"body": body}}}}}


def create_ticket(params: dict) -> dict:
    tid = _next_id()
    priority = params.get("priority", "MEDIUM").upper()
    category = params.get("category", "OTHER").upper()
    TICKETS[tid] = {
        "id": tid,
        "user_id": params.get("user_id", "unknown"),
        "category": category,
        "description": params.get("description", ""),
        "priority": priority,
        "status": "OPEN",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    return _ok(
        f"Ticket {tid} created. Category: {category}, Priority: {priority}. "
        "Our team will contact you shortly."
    )


def get_ticket_status(params: dict) -> dict:
    tid = params.get("ticket_id", "").upper()
    t = TICKETS.get(tid)
    if not t:
        return _ok(f"Ticket {tid} not found. Please check the ticket ID.")
    return _ok(
        f"Ticket {tid} — Status: {t['status']}, Category: {t['category']}, "
        f"Priority: {t['priority']}, Created: {t['created_at']}"
    )


def escalate_ticket(params: dict) -> dict:
    tid = params.get("ticket_id", "").upper()
    reason = params.get("reason", "not provided")
    t = TICKETS.get(tid)
    if not t:
        return _ok(f"Ticket {tid} not found. Please check the ticket ID.")
    t["status"] = "ESCALATED"
    t["escalation_reason"] = reason
    return _ok(
        f"Ticket {tid} escalated to Tier 2 support. Reason: {reason}. "
        "A senior technician will contact you within 2 hours."
    )


def handler(event, context):
    action = event.get("function", "")
    params = {p["name"]: p["value"] for p in event.get("parameters", [])}

    if action == "create_ticket":
        return create_ticket(params)
    if action == "get_ticket_status":
        return get_ticket_status(params)
    if action == "escalate_ticket":
        return escalate_ticket(params)

    return _ok(f"Unknown action: {action}")
