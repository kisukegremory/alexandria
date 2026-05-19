import json
from strands import tool
from data.mock_data import ACTIVITIES, SUPPORTED_DESTINATIONS


@tool
def get_activities(destination: str, duration_days: int, traveler_profile: str) -> str:
    """
    Get a day-by-day activity itinerary for the destination.

    Args:
        destination: City name — must be one of: Lisboa, Paris, Tokyo
        duration_days: Number of days of the trip
        traveler_profile: Traveler style — e.g. 'cultural', 'adventure', 'relaxed', 'couple'

    Returns:
        JSON string with a day-by-day itinerary tailored to the trip duration.
    """
    days = ACTIVITIES.get(destination)
    if not days:
        return json.dumps({
            "error": f"Destination '{destination}' not available. Supported: {SUPPORTED_DESTINATIONS}"
        })

    itinerary = days[:duration_days]
    return json.dumps({
        "destination": destination,
        "duration_days": duration_days,
        "traveler_profile": traveler_profile,
        "itinerary": itinerary,
    }, ensure_ascii=False)
