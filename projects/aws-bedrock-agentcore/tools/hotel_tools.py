import json
from strands import tool
from data.mock_data import HOTELS, SUPPORTED_DESTINATIONS


@tool
def search_hotels(destination: str, check_in: str, check_out: str, guests: int, budget: str) -> str:
    """
    Search for available hotels at the destination.

    Args:
        destination: City name — must be one of: Lisboa, Paris, Tokyo
        check_in: Check-in date in YYYY-MM-DD format
        check_out: Check-out date in YYYY-MM-DD format
        guests: Number of guests
        budget: Budget tier preference — 'budget', 'medium', or 'premium'

    Returns:
        JSON string with hotel options filtered by budget tier, including name,
        neighborhood, price per night, and rating.
    """
    options = HOTELS.get(destination)
    if not options:
        return json.dumps({
            "error": f"Destination '{destination}' not available. Supported: {SUPPORTED_DESTINATIONS}"
        })

    filtered = [h for h in options if h["tier"] == budget.lower()] or options
    return json.dumps({
        "destination": destination,
        "check_in": check_in,
        "check_out": check_out,
        "guests": guests,
        "options": filtered,
    }, ensure_ascii=False)
